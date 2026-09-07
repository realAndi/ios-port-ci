#!/bin/sh
# clang, pointed at the iPhoneOS SDK.
#
# Go's ios/arm64 port requires external (cgo) linking, so the final link is
# handed to $CC -- and it is $CC, not Go, that decides what platform the Mach-O
# claims and which framework paths get written into it. With the default macOS
# clang you get LC_BUILD_VERSION platform 1 (macOS) even though GOOS=ios, and
# CoreFoundation linked by its macOS bundle path (.framework/Versions/A/), which
# does not exist on iOS. Both are fatal on device, the build still exits 0, and
# nothing in its output tells you. check-macho.py is the backstop.
set -e
SDK=$(xcrun --sdk iphoneos --show-sdk-path)
CLANG=$(xcrun --sdk iphoneos --find clang)
exec "$CLANG" -arch arm64 -isysroot "$SDK" -mios-version-min="${IOS_MIN:-15.0}" "$@"
