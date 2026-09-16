#!/bin/bash
set -euo pipefail

APP_NAME="Amar Avro Keyboard"
EXECUTABLE_NAME="AmarAvroKeyboard"
INSTALL_DIR="$HOME/Library/Input Methods"
USER_DATA_DIR="$HOME/Library/Application Support/Amar Avro Keyboard"
PREFS_FILE="$HOME/Library/Preferences/com.amaravrokeyboard.inputmethod.AmarAvroKeyboard.plist"
LEGACY_PREFS_FILE="$HOME/Library/Preferences/com.amaravrokeyboard.pkg.plist"
SAVED_STATE_DIR="$HOME/Library/Saved Application State/com.amaravrokeyboard.inputmethod.AmarAvroKeyboard.savedState"
LEGACY_SAVED_STATE_DIR="$HOME/Library/Saved Application State/com.amaravrokeyboard.pkg.savedState"

echo "=== Uninstalling $APP_NAME ==="

# Kill running instance
killall "$EXECUTABLE_NAME" 2>/dev/null || true
sleep 1

# Remove the app
if [ -d "$INSTALL_DIR/$APP_NAME.app" ]; then
    echo ">>> Removing $INSTALL_DIR/$APP_NAME.app"
    rm -rf "$INSTALL_DIR/$APP_NAME.app"
else
    echo ">>> App not found in $INSTALL_DIR"
fi

rm -f "/Applications/$APP_NAME.app" 2>/dev/null || true

# Ask about user data
if [ -d "$USER_DATA_DIR" ] || [ -f "$PREFS_FILE" ] || [ -f "$LEGACY_PREFS_FILE" ] || [ -d "$SAVED_STATE_DIR" ] || [ -d "$LEGACY_SAVED_STATE_DIR" ]; then
    echo ""
    echo "User data found:"
    [ -d "$USER_DATA_DIR" ]   && echo "  - $USER_DATA_DIR (learned word selections)"
    [ -f "$PREFS_FILE" ]      && echo "  - $PREFS_FILE (settings)"
    [ -f "$LEGACY_PREFS_FILE" ] && echo "  - $LEGACY_PREFS_FILE (legacy settings)"
    [ -d "$SAVED_STATE_DIR" ] && echo "  - $SAVED_STATE_DIR (welcome window state)"
    echo ""
    read -p "Remove all user data? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$USER_DATA_DIR"   2>/dev/null || true
        rm -f  "$PREFS_FILE"      2>/dev/null || true
        rm -f  "$LEGACY_PREFS_FILE" 2>/dev/null || true
        rm -rf "$SAVED_STATE_DIR" 2>/dev/null || true
        rm -rf "$LEGACY_SAVED_STATE_DIR" 2>/dev/null || true
        echo ">>> User data removed."
    else
        echo ">>> User data preserved."
    fi
fi

echo ""
echo "=== Uninstall complete ==="
echo "Please log out and log back in to complete removal."
