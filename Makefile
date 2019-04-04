VERSION=2.0.0
PREFIX?=/usr/local

BINARIES_DIR=/usr/local/bin
BUILD_DIR=.build/release

REPO=https://github.com/giginet/Toybox
RELEASE_TAR = $(REPO)/archive/$(VERSION).tar.gz
SHA = $(shell curl -L -s $(RELEASE_TAR) | shasum -a 256 | sed 's/ .*//')

.PHONY: all bootstrap clean install package test uninstall update_brew make_bottle

all: bootstrap


bootstrap:
	swift package generate-xcodeproj

test: clean
	swift test

clean:
	swift package clean

uninstall:
	rm -f "$(BINARIES_DIR)/toybox"

installables: clean
	swift build -c release --disable-sandbox --disable-package-manifest-caching

prefix_install: installables
	mkdir -p "$(PREFIX)/bin"
	cp -f "$(BUILD_DIR)/toybox" "$(PREFIX)/bin/"

update_brew:
	sed -i '' 's|\(url ".*/archive/\)\(.*\)\(.tar\)|\1$(VERSION)\3|' Formula/toybox.rb
	sed -i '' 's|\(sha256 "\)\(.*\)\("\)|\1$(SHA)\3|' Formula/toybox.rb

make_bottle:
	brew tap giginet/toybox file://`pwd`
	brew install giginet/toybox/toybox --verbose --build-bottle
	brew bottle giginet/toybox/toybox

