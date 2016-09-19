# Toybox

Toybox made easy to manage Xcode Playgrounds.

## Before Toybox

## Using Toybox

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
```

Created Playgrounds will be saved under `$HOME/.toybox`

### List Playground

```sh
# List all existing playgrounds
$ toybox list
# List all playgrounds for specific platform
$ toybox list --platform ios
```

### Open Playground

```sh
# Open UIKitDemo.playground with default Xcode
$ toybox open UIKitDemo
```

### Other

```sh
# Display current Toybox version
$ toybox version
# Display path to Toybox root directory,
# It should return '$HOME/.toybox'
$ toybox root
```

## Installation

You can install Toybox via Homebrew.

```sh
$ brew tap giginet/toybox
$ brew install giginet/toybox/toybox
```
