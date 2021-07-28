SHELL := /bin/bash

PATHVER?=2.0
VERSION?=2.0.5
RELEASEVER?=1
SCRIPTPATH=$(shell pwd -P)

build: clean luajit pre_package

clean:
	rm -rf /tmp/luajit-$(PATHVER)

luajit:
	# Download and install luajit
	cd /tmp/ && \
	git clone https://github.com/LuaJIT/LuaJIT --branch v$(VERSION) /tmp/luajit-$(PATHVER) && \
	cd /tmp/luajit-$(PATHVER) && \
	make -j$(CORES)

pre_package:
	cd /tmp/luajit-$(PATHVER) && make install DESTDIR=/tmp/luajit-install

fpm_debian:
	fpm -s dir \
		-t deb \
		-n luajit-$(PATHVER) \
		-v $(VERSION)-$(RELEASEVER)~$(shell lsb_release --codename | cut -f2) \
		-C /tmp/luajit-install \
		-p luajit-$(PATHVER)-$(VERSION)-$(RELEASEVER)~$(shell lsb_release --codename | cut -f2)_$(shell arch).deb \
		-m "charlesportwoodii@erianna.com" \
		--license "MIT" \
		--url https://github.com/charlesportwoodii/luajit-build \
		--description "Lua JIT $(PATHVER)" \
		--deb-systemd-restart-after-upgrade

fpm_rpm:
	fpm -s dir \
		-t rpm \
		-n luajit-$(PATHVER) \
		-v $(VERSION)-$(RELEASEVER) \
		-C /tmp/luajit-install \
		-p luajit-$(PATHVER)-$(VERSION)-$(RELEASEVER)_$(shell arch).rpm \
		-m "charlesportwoodii@erianna.com" \
		--license "MIT" \
		--url https://github.com/charlesportwoodii/luajit-build \
		--description "Lua JIT $(PATHVER)" \
		--vendor "Charles R. Portwood II" \
		--rpm-digest sha384 \
		--rpm-compression gzip

fpm_alpine:
	fpm -s dir \
		-t apk \
		-n luajit-$(PATHVER) \
		-v $(VERSION)-$(RELEASEVER)~$(shell uname -m) \
		-C /tmp/luajit-install \
		-p luajit-$(PATHVER)-$(VERSION)-$(RELEASEVER)~$(shell uname -m).apk \
		-m "charlesportwoodii@erianna.com" \
		--license "MIT" \
		--url https://github.com/charlesportwoodii/luajit-build \
		--description "Lua JIT $(PATHVER)" \
		--force \
		-a $(shell uname -m)
