#!/bin.bash
set -euo pipefail
for arch in arm64 armhf amd64; do
	clickable build --arch $arch
done

for arch in arm64 armhf amd64; do
	clickable publish --arch $arch
done
