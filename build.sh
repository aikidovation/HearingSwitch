#!/bin/zsh
# Builds build/HearingSwitch.app (arm64 only, ad-hoc signed). Does not launch it.
set -e
cd "$(dirname "$0")"
APP=build/HearingSwitch.app
rm -rf "$APP"; mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp Resources/Info.plist "$APP/Contents/Info.plist"
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
xcrun swiftc -O -target arm64-apple-macos13.0 -parse-as-library \
  -o "$APP/Contents/MacOS/HearingSwitch" Sources/*.swift
codesign --force --sign - "$APP"
echo "Built $PWD/$APP"
