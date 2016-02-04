SHELL := /bin/bash

RELEASEVER?=1
RELEASE=$(shell lsb_release --codename | cut -f2)
SCRIPTPATH=$(shell pwd -P)

build: clean luajit

clean:
	rm -rf /tmp/luajit-2.0

luajit:
	# Download and install libluajit
	cd /tmp/ && \
	git clone http://luajit.org/git/luajit-2.0.git && \
	cd /tmp/luajit-2.0 && \
	make -j$(CORES) && \
	make install

package:
	# Copy Packaging tools
	cp -R $(SCRIPTPATH)/*-pak /tmp/luajit-2.0

	cd /tmp/luajit-2.0 && \
	checkinstall \
		-D \
		--fstrans \
		-pkgname luajit-2.0 \
		-pkgrelease "$(RELEASEVER)"~"$(RELEASE)" \
		-pkglicense MIT \
		-pkggroup lua \
		-maintainer charlesportwoodii@ethreal.net \
		-provides "luajit-2.0" \
		-pakdir /tmp \
		-y