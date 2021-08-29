import os
import sys

import requests
import pyotherside

from html.parser import HTMLParser
from concurrent.futures import ThreadPoolExecutor
from functools import lru_cache
from urllib.parse import urlparse
from urllib.request import Request, urlopen
from pathlib import Path

here = os.path.abspath(os.path.dirname(__file__))

vendored = os.path.join(here, '..', 'vendored')
sys.path.insert(0, vendored)

from pykeepass_rs import get_all_entries

ENTRIES = []
CACHE_PATH = Path('/home/phablet/.cache/keepass.davidv.dev')
CACHE_ICON_PATH = CACHE_PATH / 'icons'
LOCAL_ICON_PATH = Path(here) / Path('../assets/icons')
kp = None
tpe = ThreadPoolExecutor()


CACHE_ICON_PATH.mkdir(parents=True, exist_ok=True)


def open_db(db_path, key_path, password):
    global ENTRIES
    try:
        ENTRIES = get_all_entries(db_path, password=password or None, keyfile=key_path or None)
        pass
    except OSError as e:
        print("Bad creds! bye", e, flush=True)
        pyotherside.send('db_open_fail', str(e))
        return

    pyotherside.send('db_open')

def get_groups():
    return sorted(set(e['group'] for e in ENTRIES))

def get_entries(group_name, search_term):
    print('search term', search_term, flush=True)
    return [{**entry, 'icon_path': str(get_icon_path(domain(entry['url'])))}
            for entry in ENTRIES
            if group_name in entry['group'] and
            (search_term in entry['username'] or
             search_term in entry['url'] or
             search_term in entry['title'])]


def domain(url):
    if '/' not in url:
        return url
    return urlparse(url).netloc

@lru_cache(maxsize=512) # hack to avoid calling this repeatedly
def fetch_icon(domain):
    if not domain:
        return
    print('fetching', domain)

    url = 'https://' + domain
    req = Request(url)
    req.add_header('user-agent', 'curl/7.68.0')
    req.add_header('accept', '*/*')
    req.add_header('Host', domain)

    try:
        html_reply = requests.get(url, timeout=2)
    except Exception as e:
        print('While fetching HTML for', url, e, flush=True)
        return
    if not html_reply.ok:
        #print(html_reply.text)
        #print(html_reply.url, html_reply.headers, html_reply.status_code, flush=True)
        print('failed', html_reply.url)
        return

    data = html_reply.text

    icon_urls = html_to_icon(data)
    if not icon_urls:
        return

    print('For', domain,  'found', icon_urls)
    icon_url = icon_urls[0]
    if '//' not in icon_url:
        if not icon_url.startswith('/'):
            icon_url = '/' + icon_url
        icon_url = 'https://' + domain + icon_url
    if icon_url.startswith('//'):
        icon_url = 'https:' + icon_url

    req = Request(icon_url)
    req.add_header('user-agent', 'curl/7.68.0')
    try:
        with urlopen(req, timeout=5) as reply:
            if reply.status != 200:
                print(reply.url, reply.headers, reply.status, flush=True)
                return
            icon_data = reply.read()
    except Exception as e:
        print('While fetching icon for', icon_url, e, flush=True)
        return

    with get_icon_path(domain).open('wb') as fd:
        fd.write(icon_data)

@lru_cache(maxsize=512)
def get_icon_path(domain):
    domain = domain.replace('.', '_')
    path = LOCAL_ICON_PATH / domain
    if not path.exists():
        path = CACHE_ICON_PATH / domain
    return path


def fetch_all_icons():
    for e in ENTRIES:
        d = domain(e['url'])

        icon_path = get_icon_path(d)
        print(e, d, icon_path)
        if not icon_path.exists():
            tpe.submit(fetch_icon, d)
            # fetch_icon(d)

def html_to_icon(h):
    class HTMLFilter(HTMLParser):
        def __init__(self):
            super().__init__()
            self.icons = []

        def handle_starttag(self, tag, attrs):
            if tag == 'link':
                if 'icon' in dict(attrs).get('rel'):
                    self.icons.append(dict(attrs)['href'])

    f = HTMLFilter()
    f.feed(h)
    return f.icons
