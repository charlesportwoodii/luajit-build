SHELL := /bin/bash

RELEASEVER?=1
SCRIPTPATH=$(shell pwd -P)

build: clean luajit

clean:
	rm -rf /tmp/luajit-2.0

luajit:
	# Download and install libluajit
	cd /tmp/ && \
	git clone http://luajit.org/git/luajit-2.0.git && \
	cd /tmp/luajit-2.0 && \
	make -j$(CORES)

fpm_debian:
	echo "Packaging libbrotli for Debian"

	cd /tmp/luajit-2.0 && make install DESTDIR=/tmp/luajit-install

	fpm -s dir \
		-t deb \
		-n luajit-2.0 \
		-v 2.0-$(RELEASEVER)~$(shell lsb_release --codename | cut -f2) \
		-C /tmp/luajit-install \
		-p luajit-2.0_$(RELEASEVER)~$(shell lsb_release --codename | cut -f2)_$(shell arch).deb \
		-m "charlesportwoodii@erianna.com" \
		--license "MIT" \
		--url https://github.com/charlesportwoodii/luajit-build \
		--description "Lua JIT 2.0" \
		--deb-systemd-restart-after-upgrade

fpm_rpm:
	echo "Packaging libbrotli for RPM"

	cd /tmp/luajit-2.0 && make install DESTDIR=/tmp/luajit-install

	fpm -s dir \
		-t rpm \
		-n luajit-2.0 \
		-v /tmp/ \
		-C /tmp/luajit-install \
		-p luajit-2.0_$(RELEASEVER)~_$(shell arch).rpm \
		-m "charlesportwoodii@erianna.com" \
		--license "MIT" \
		--url https://github.com/charlesportwoodii/luajit-build \
		--description "Lua JIT 2.0" \
		--vendor "Charles R. Portwood II" \
		--rpm-digest sha384 \
		--rpm-compression gzip
