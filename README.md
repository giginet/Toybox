# Toybox

[![Build Status](https://travis-ci.org/giginet/Toybox.svg?branch=master)](https://travis-ci.org/giginet/Toybox)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/giginet/Toybox/master/LICENSE.md) 
[![GitHub release](https://img.shields.io/github/release/giginet/Toybox.svg)](https://github.com/giginet/Toybox/releases)
[![Language](https://img.shields.io/badge/language-Swift%203-orange.svg)](https://swift.org)


Toybox made easy to manage Xcode Playgrounds.

This product is under development so interfaces might change.

## Before Toybox

![](Documentation/Images/before.gif)

## Using Toybox

![](Documentation/Images/after.gif)

## Installation

### Homebrew

You can install Toybox via [Homebrew](http://brew.sh/index.html).

```sh
$ brew tap giginet/toybox
$ brew install giginet/toybox/toybox
```

Xcode 8 is required.

### Installer

Download installer from [Releases](https://github.com/giginet/Toybox/releases/download/0.1.0/toybox.pkg)

## Features

### Create new Playground

```sh
# Create new Playground for iOS named with timestamp
$ toybox create
# Create 'UIKitDemo.playground' for iOS
$ toybox create UIKitDemo
# Create 'SpriteKit.playground' for macOS
$ toybox create SpriteKitDemo --platform macos
# Overwrite existing playground 'UIKitDemo'
$ toybox create UIKitDemo -f
# Create but don't open with Xcode
$ toybox create UIKitDemo --no-open
# Create and open with specific Xcode
$ toybox create UIKitDemo --xcode-path /Application/Xcode7.3.app
# Create Playground from standard input
$ echo 'print("Hello World")' | toybox create --input
```

Created Playgrounds will be saved under `$HOME/.toybox`

### List Playgrounds

```sh
# List all existing playgrounds
$ toybox list
# List all playgrounds of specific platform
$ toybox list --platform ios
```

### Open Playground

```sh
# Open UIKitDemo.playground with default Xcode
$ toybox open UIKitDemo
# Open UIKitDemo.playground with specific Xcode
$ toybox open UIKitDemo --xcode-path /Application/Xcode7.3.app
```

### Other

```sh
# Display current Toybox version
$ toybox version
# Display path to Toybox root directory,
# It should return '$HOME/.toybox'
$ toybox root
```

## Extra Usage

Open existing playgrouds with [peco](https://github.com/peco/peco)

```sh
toybox list | peco | sed -E 's/\(.*\)$//g' | xargs toybox open
```

## Author

giginet <<giginet.net@gmail.com>>

## License

MIT License
