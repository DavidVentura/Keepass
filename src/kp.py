import os
import sys
import pyotherside
here = os.path.abspath(os.path.dirname(__file__))

vendored = os.path.join(here, '..', 'vendored')
sys.path.insert(0, vendored)

from pykeepass_rs import get_all_entries

CONFIG = {'key_path': ''}
ENTRIES = []
kp = None

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
    except OSError as e:
        print("Bad creds! bye", e, flush=True)
        return

    pyotherside.send('db_open')

def get_groups():
    return sorted(set(e['group'] for e in ENTRIES))

def get_entries(group_name):
    #group = kp.find_groups(name=group_name, first=True)

    return [entry
            for entry in ENTRIES
            if group_name in entry['group']]

set_file('/home/phablet/atest.kdbx', True)
