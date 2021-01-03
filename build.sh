#!/bin/sh
set -eux

apk add build-base linux-headers openssl-dev openssl-libs-static

wget https://www.stunnel.org/downloads/stunnel-$STUNNEL_VERSION.tar.gz
tar -xf stunnel-$STUNNEL_VERSION.tar.gz

cd stunnel-$STUNNEL_VERSION

# Enfore static linking. This is a nasty workaround, but autohells...
sed -i 's/^stunnel_LDFLAGS = /&-all-static /' src/Makefile.in

export CFLAGS='-Os -fomit-frame-pointer -pipe'
./configure \
	--prefix=/usr/local \
	--sysconfdir=/etc \
	--localstatedir=/var \
	--disable-fips \
	--disable-shared \
	--enable-static \
	--disable-silent-rules
make

ls -la src/stunnel
strip src/stunnel
file src/stunnel

BIN_NAME="stunnel-$STUNNEL_VERSION-$(uname -m)-linux"

mkdir -p ../dist
mv src/stunnel ../dist/$BIN_NAME

cd ../dist
sha1sum $BIN_NAME > $BIN_NAME.sha1
