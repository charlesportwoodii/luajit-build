SHELL := /bin/bash

VERSION?=2.0.5
RELEASEVER?=1
SCRIPTPATH=$(shell pwd -P)

build: clean luajit pre_package

clean:
	rm -rf /tmp/luajit-2.0

luajit:
	# Download and install luajit
	cd /tmp/ && \
	git clone http://luajit.org/git/luajit-2.0.git --branch v$(VERSION) && \
	cd /tmp/luajit-2.0 && \
	make -j$(CORES)

pre_package:
	cd /tmp/luajit-2.0 && make install DESTDIR=/tmp/luajit-install

fpm_debian:
	fpm -s dir \
		-t deb \
		-n luajit-2.0 \
		-v $(VERSION)-$(RELEASEVER)~$(shell lsb_release --codename | cut -f2) \
		-C /tmp/luajit-install \
		-p luajit-$(VERSION)-$(RELEASEVER)~$(shell lsb_release --codename | cut -f2)_$(shell arch).deb \
		-m "charlesportwoodii@erianna.com" \
		--license "MIT" \
		--url https://github.com/charlesportwoodii/luajit-build \
		--description "Lua JIT 2.0" \
		--deb-systemd-restart-after-upgrade \
		-a $(shell arch)

fpm_rpm: pre_package
	fpm -s dir \
		-t rpm \
		-n luajit-2.0 \
		-v $(VERSION)-$(RELEASEVER) \
		-C /tmp/luajit-install \
		-p luajit-$(VERSION)-$(RELEASEVER)_$(shell arch).rpm \
		-m "charlesportwoodii@erianna.com" \
		--license "MIT" \
		--url https://github.com/charlesportwoodii/luajit-build \
		--description "Lua JIT 2.0" \
		--vendor "Charles R. Portwood II" \
		--rpm-digest sha384 \
		--rpm-compression gzip \
		-a $(shell arch)

fpm_alpine:
	fpm -s dir \
		-t apk \
		-n luajit-2.0 \
		-v $(VERSION)-$(RELEASEVER)~$(shell uname -m) \
		-C /tmp/luajit-install \
		-p luajit-$(VERSION)-$(RELEASEVER)~$(shell uname -m).apk \
		-m "charlesportwoodii@erianna.com" \
		--license "MIT" \
		--url https://github.com/charlesportwoodii/luajit-build \
		--description "Lua JIT 2.0" \
		--force \
		-a $(shell uname -m)
