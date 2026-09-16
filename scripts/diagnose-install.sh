#!/bin/bash
set -u

APP="$HOME/Library/Input Methods/Amar Avro Keyboard.app"
PLIST="$APP/Contents/Info.plist"
EXPECTED_ID="com.amaravrokeyboard.inputmethod.AmarAvroKeyboard"

echo "=== Amar Avro Keyboard installation check ==="

if [ ! -d "$APP" ]; then
    echo "FAIL: App is not installed at: $APP"
    exit 1
fi

if [ ! -f "$PLIST" ]; then
    echo "FAIL: Info.plist is missing."
    exit 1
fi

ACTUAL_ID=$(plutil -extract CFBundleIdentifier raw -o - "$PLIST" 2>/dev/null || true)
echo "Installed app: $APP"
echo "Bundle ID: $ACTUAL_ID"

if [ "$ACTUAL_ID" != "$EXPECTED_ID" ]; then
    echo "FAIL: Wrong Input Method bundle identifier."
    exit 1
fi

if codesign --verify --deep --strict "$APP" 2>/dev/null; then
    echo "Code signature: valid"
else
    echo "FAIL: Code signature verification failed."
    exit 1
fi

echo "PASS: The installed bundle has valid Input Method metadata."
echo "Open System Settings → Keyboard → Text Input → Edit → + → Bengali."
