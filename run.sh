#!/bin/sh
set -e
arch=arm64
ip=192.168.2.155
ip=192.168.2.156
arch=armhf
ip=192.168.2.176
clickable build   --arch $arch --skip-review --ssh $ip
clickable install --arch $arch --ssh $ip
clickable launch  --arch $arch --ssh $ip
clickable logs    --arch $arch --ssh $ip
