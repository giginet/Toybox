VERSION = 1.0.1
TEMPORARY_FOLDER?=/tmp/Toybox.dst
PREFIX?=/usr/local

XCODEFLAGS=-project 'Toybox.xcodeproj' -scheme 'toybox' DSTROOT=$(TEMPORARY_FOLDER)

OUTPUT_PACKAGE=toybox.pkg
OUTPUT_FRAMEWORK=ToyboxKit.framework
OUTPUT_FRAMEWORK_ZIP=ToyboxKit.framework.zip

BUILT_BUNDLE=$(TEMPORARY_FOLDER)/Applications/toybox.app
TOYBOXKIT_BUNDLE=$(BUILT_BUNDLE)/Contents/Frameworks/$(OUTPUT_FRAMEWORK)
TOYBOX_EXECUTABLE=$(BUILT_BUNDLE)/Contents/MacOS/toybox

FRAMEWORKS_FOLDER=/Library/Frameworks
BINARIES_FOLDER=/usr/local/bin

VERSION_STRING=$(shell agvtool what-marketing-version -terse1)
COMPONENTS_PLIST=Sources/toybox/Components.plist

REPO=https://github.com/giginet/Toybox
RELEASE_TAR = $(REPO)/archive/$(VERSION).tar.gz
SHA = $(shell curl -L -s $(RELEASE_TAR) | shasum -a 256 | sed 's/ .*//')

.PHONY: all bootstrap clean install package test uninstall update_brew make_bottle

all: bootstrap
	xcodebuild $(XCODEFLAGS) build

bootstrap:
	carthage update --platform macOS

test: clean bootstrap
	xcodebuild $(XCODEFLAGS) test

clean:
	rm -f "$(OUTPUT_PACKAGE)"
	rm -f "$(OUTPUT_FRAMEWORK_ZIP)"
	rm -rf "$(TEMPORARY_FOLDER)"
	xcodebuild $(XCODEFLAGS) clean

install: package
	sudo installer -pkg Toybox.pkg -target /

uninstall:
	rm -rf "$(FRAMEWORKS_FOLDER)/$(OUTPUT_FRAMEWORK)"
	rm -f "$(BINARIES_FOLDER)/toybox"

installables: clean bootstrap
	xcodebuild $(XCODEFLAGS) install

	mkdir -p "$(TEMPORARY_FOLDER)$(FRAMEWORKS_FOLDER)" "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)"
	mv -f "$(TOYBOXKIT_BUNDLE)" "$(TEMPORARY_FOLDER)$(FRAMEWORKS_FOLDER)/$(OUTPUT_FRAMEWORK)"
	mv -f "$(TOYBOX_EXECUTABLE)" "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)/toybox"
	rm -rf "$(BUILT_BUNDLE)"

prefix_install: installables
	mkdir -p "$(PREFIX)/Frameworks" "$(PREFIX)/bin"
	cp -rf "$(TEMPORARY_FOLDER)$(FRAMEWORKS_FOLDER)/$(OUTPUT_FRAMEWORK)" "$(PREFIX)/Frameworks/"
	cp -f "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)/toybox" "$(PREFIX)/bin/"
	install_name_tool -add_rpath "@executable_path/../Frameworks/$(OUTPUT_FRAMEWORK)/Versions/Current/Frameworks/"  "$(PREFIX)/bin/toybox"

package: installables
	pkgbuild \
		--component-plist "$(COMPONENTS_PLIST)" \
		--identifier "org.giginet.toybox" \
		--install-location "/" \
		--root "$(TEMPORARY_FOLDER)" \
		--version "$(VERSION_STRING)" \
		"$(OUTPUT_PACKAGE)"
	
	(cd "$(TEMPORARY_FOLDER)$(FRAMEWORKS_FOLDER)" && zip -q -r --symlinks - "$(OUTPUT_FRAMEWORK)") > "$(OUTPUT_FRAMEWORK_ZIP)"

update_brew:
	sed -i '' 's|\(url ".*/archive/\)\(.*\)\(.tar\)|\1$(VERSION)\3|' Formula/toybox.rb
	sed -i '' 's|\(sha256 "\)\(.*\)\("\)|\1$(SHA)\3|' Formula/toybox.rb

make_bottle:
	brew tap giginet/toybox file://`pwd`
	brew install giginet/toybox/toybox --verbose --build-bottle
	brew bottle giginet/toybox/toybox

