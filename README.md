# Keepass

Ubuntu Phone app to view entries in a KeePass (kdbx, kdbx3, kdbx4) file.  
Uses [keepass-rs](https://github.com/sseemayer/keepass-rs) via [pykeepass-rs](https://github.com/DavidVentura/pykeepass-rs).  
The app will remain read only as long as keepass-rs does not implement writing features. If you want those features,
please go to keepass-rs first.

## Features

- Support kdbx (version 1-4) as per [keepass-rs](https://github.com/sseemayer/keepass-rs)
  - Fast! 135 entries take 270ms on my phone, compared to 9.5s when using pykeepass
- Multiple entry groups
- Search in entries
- Tap-to-reveal password
- Open URL from entry
- Copy user/password to clipboard
- Download icons from your saved urls (optional, disabled by default)
  - There's a pre-populated bunch of icons, feel free to contribute more

## Screenshots

![](https://github.com/davidventura/Keepass/blob/master/screenshots/confined.png?raw=true)
![](https://github.com/davidventura/Keepass/blob/master/screenshots/main.png?raw=true)
![](https://github.com/davidventura/Keepass/blob/master/screenshots/settings.png?raw=true)

You can also type in arbitrary paths if your files are kept in sync via some mechanism.
![](https://github.com/davidventura/Keepass/blob/master/screenshots/unconfined.png?raw=true)



## Test database

In the repo there's a test db with some entries and groups. The password is `somePassw0rd`.
