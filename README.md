# Keepass

View entries in a KeePass (kdbx, kdbx3, kdbx4) file

## Vendoring

```bash
# Install base pip
apt-get install python3-pip
# Install latest pip with support for py3.5
# 21.0 dropped it: https://pip.pypa.io/en/stable/news/#v21-0
pip3 install -U pip==20.3.4
# Install dependencies
apt-get install python3-setuptools libxml2-dev libxslt-dev python3-dev gcc libffi-dev zlib1g-dev
# Install wheel
pip3 install -U wheel
# Install pykeepass into a vendored dir
pip3 install -t aarch64 pykeepass
```


## Test database

In the repo there's a test db with some entries and groups. The password is `somePassw0rd`.
