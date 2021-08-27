import os
import sys
import pyotherside

from urllib.parse import urlparse
from pathlib import Path

here = os.path.abspath(os.path.dirname(__file__))

vendored = os.path.join(here, '..', 'vendored')
sys.path.insert(0, vendored)

from pykeepass_rs import get_all_entries

CONFIG = {'key_path': ''}
ENTRIES = []
CACHE_PATH = Path('/home/phablet/.cache/keepass.davidv.dev')
ICON_PATH = CACHE_PATH / 'icons'
kp = None

ICON_PATH.mkdir(exist_ok=True)

def save_config():
    pyotherside.send('config', CONFIG)

def set_file(path, is_db):
    if not is_db:
        CONFIG['key_path'] = path
    else:
        CONFIG['db_path'] = path

    save_config()

def open_db(password):
    global ENTRIES
    try:
        ENTRIES = get_all_entries(CONFIG['db_path'], password=password or None, keyfile=CONFIG['key_path'] or None)
        pass
    except OSError as e:
        print("Bad creds! bye", e, flush=True)
        return

    pyotherside.send('db_open')

def get_groups():
    return sorted(set(e['group'] for e in ENTRIES))

def get_entries(group_name):
    #group = kp.find_groups(name=group_name, first=True)
    return [{**entry, 'icon_path': get_icon_path(domain(entry['url']))}
            for entry in ENTRIES
            if group_name in entry['group']]


def domain(url):
    return urlparse(url).netloc

def fetch_icon(url):
    return
    r = requests.get(domain(url) + '/favicon.ico')
    if r.ok:
        return r.text

def get_icon_path(domain):
    # TODO: if resource || local
    path = ICON_PATH / (domain + '.ico')
    return str(path)

def save_icon(domain, icon_data):
    pass

def fetch_all_icons():
    for e in ENTRIES:
        d = domain(e['url'])
        if not get_icon_path(d):
            icon = fetch_icon(d)
            if icon:
                save_icon(d, icon)

set_file('/home/phablet/atest.kdbx', True)
