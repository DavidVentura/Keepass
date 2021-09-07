import os
import sys
import platform

import requests
import pyotherside

from html.parser import HTMLParser
from collections import defaultdict
from concurrent.futures import ThreadPoolExecutor
from functools import lru_cache
from urllib.parse import urlparse
from urllib.request import Request, urlopen
from pathlib import Path

here = os.path.abspath(os.path.dirname(__file__))

vendored = os.path.join(here, '..', 'vendored')
sys.path.insert(0, vendored)

from pykeepass_rs import get_meta_and_entries, get_db_version

ENTRIES = []
GROUPS = []
META = {}
CACHE_PATH = Path('/home/phablet/.cache/keepass.davidv.dev')
CACHE_ICON_PATH = CACHE_PATH / 'icons'
FAILED_ICON_PATH = CACHE_PATH / 'failed_icons'
LOCAL_ICON_PATH = Path(here) / Path('../assets/icons')
PLACEHOLDER_ICON = Path(here) / Path('../assets/placeholder.png')
APP_DATA_PATH = Path('/home/phablet/.local/share/keepass.davidv.dev')
KEY_DB_PATH = APP_DATA_PATH / 'keys_and_dbs'
kp = None
tpe = ThreadPoolExecutor()


CACHE_ICON_PATH.mkdir(parents=True, exist_ok=True)
FAILED_ICON_PATH.mkdir(parents=True, exist_ok=True)
KEY_DB_PATH.mkdir(parents=True, exist_ok=True)

def is_db_v3(path):
    return get_db_version(path) == 3

def is_armv7():
    return '32' in platform.architecture()[0]

def set_file(path, is_db):
    path = Path(path)
    with path.open('rb') as fd_from:
        to = KEY_DB_PATH / path.name
        with to.open('wb') as fd_to:
            fd_to.write(fd_from.read())
        return str(to)

def open_db(db_path, key_path, password):
    global META, ENTRIES, GROUPS
    try:
        META, GROUPS, ENTRIES = get_meta_and_entries(db_path, password=password or None, keyfile=key_path or None)
    except OSError as e:
        print("Bad creds! bye", e, flush=True)
        pyotherside.send('db_open_fail', str(e))
        return

    pyotherside.send('db_open')

def get_groups(show_recycle_bin):
    _groups = []
    _trash_name = ''
    for g in GROUPS:
        if g.uuid == META.recycle_bin_uuid:
            _trash_name = g.name
            continue
        _groups.append(g.name)

    if show_recycle_bin:
        _groups.append(_trash_name)
    return _groups

def get_entries(search_term):
    search_term = search_term.lower()
    _entries = defaultdict(list)
    for entry in ENTRIES:
        if not (search_term in entry.username.lower() or
                search_term in entry.url.lower() or
                search_term in entry.title.lower()):
            continue
        _path = get_icon_path(domain(entry.url))
        if not _path.is_file():
            _path = PLACEHOLDER_ICON
        _entry = {'url': entry.url,
                  'username': entry.username,
                  'title': entry.title,
                  'password': entry.password,
                  'icon_path': str(_path),
                  }

        _entries[entry.group.name].append(_entry)
    return dict(_entries)


def domain(url):
    if not url:
        return ''
    if '/' not in url:
        return url
    return urlparse(url).netloc

def is_failed(domain):
    return (FAILED_ICON_PATH / domain).exists()

def mark_failed(domain):
    with (FAILED_ICON_PATH / domain).open('w'):
        pass

@lru_cache(maxsize=512) # hack to avoid calling this repeatedly
def fetch_icon(domain):
    if not domain:
        return

    url = 'https://' + domain
    req = Request(url)
    req.add_header('user-agent', 'curl/7.68.0')
    req.add_header('accept', '*/*')
    req.add_header('Host', domain)

    try:
        html_reply = requests.get(url, timeout=2)
    except Exception as e:
        print('While fetching HTML for', url, e, flush=True)
        mark_failed(domain)
        return
    if not html_reply.ok:
        print('failed', html_reply.url)
        mark_failed(domain)
        return

    data = html_reply.text

    icon_urls = html_to_icon(data)
    if not icon_urls:
        mark_failed(domain)
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
                mark_failed(domain)
                return
            icon_data = reply.read()
    except Exception as e:
        print('While fetching icon for', icon_url, e, flush=True)
        mark_failed(domain)
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
        d = domain(e.url)
        if is_failed(d):
            continue

        icon_path = get_icon_path(d)
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
