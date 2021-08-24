import os
import sys
import pyotherside
here = os.path.abspath(os.path.dirname(__file__))

vendored = os.path.join(here, 'vendored')
sys.path.insert(0, vendored)

from pykeepass import PyKeePass
from pykeepass.exceptions import CredentialsError

print(os.listdir('/home/phablet'), flush=True)
CONFIG = {'key_path': None}
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
    global kp
    try:
        kp = PyKeePass(CONFIG['db_path'], keyfile=CONFIG['key_path'], password=password)
    except CredentialsError:
        print("Bad creds! bye", flush=True)
        return

    pyotherside.send('db_open')

def get_entries():

    return [{'url': entry.url,
             'title': entry.title,
             'username': entry.username,
             'password': entry.password,
             'group': entry.group}
            for entry in kp.entries]

set_file('/home/phablet/test.kdbx', True)
