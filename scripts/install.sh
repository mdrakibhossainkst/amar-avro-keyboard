#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="Amar Avro Keyboard"
EXECUTABLE_NAME="AmarAvroKeyboard"
APP_BUNDLE="$PROJECT_ROOT/build/$APP_NAME.app"
INSTALL_DIR="$HOME/Library/Input Methods"

if [ ! -d "$APP_BUNDLE" ]; then
    echo "Error: $APP_BUNDLE not found. Run ./scripts/build.sh first."
    exit 1
fi

echo "=== Installing $APP_NAME ==="

# Kill existing instance if running
killall "$EXECUTABLE_NAME" 2>/dev/null || true
sleep 1

# Create install directory if needed
mkdir -p "$INSTALL_DIR"

# Replace only this product's existing installation.
rm -rf "$INSTALL_DIR/$APP_NAME.app" 2>/dev/null || true

# Copy new build
echo ">>> Copying $APP_NAME.app to $INSTALL_DIR/..."
cp -R "$APP_BUNDLE" "$INSTALL_DIR/"

# Clear extended attributes
xattr -cr "$INSTALL_DIR/$APP_NAME.app" 2>/dev/null || true
touch "$INSTALL_DIR/$APP_NAME.app"

# Ask Launch Services and the input menu to discover the new bundle now.
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
if [ -x "$LSREGISTER" ]; then
    "$LSREGISTER" -f "$INSTALL_DIR/$APP_NAME.app" >/dev/null 2>&1 || true
fi
killall TextInputMenuAgent 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

# Place a symlink in /Applications/ so the app shows in Launchpad/Spotlight
rm -f "/Applications/$APP_NAME.app" 2>/dev/null || true
rm -rf "/Applications/$APP_NAME.app" 2>/dev/null || true
ln -sf "$INSTALL_DIR/$APP_NAME.app" "/Applications/$APP_NAME.app" 2>/dev/null || true

# Relaunch the app so it's running in background
echo ">>> Launching $APP_NAME..."
open "$INSTALL_DIR/$APP_NAME.app"

echo ""
echo "=== Installation complete ==="
echo ""
echo "If this is a first-time install:"
echo "  1. Go to System Settings → Keyboard → Text Input → Edit"
echo "  2. Click '+' → Bengali → select 'Amar Avro Keyboard'"
echo "  3. Use Ctrl+Space (or Globe key) to switch input methods"
echo "  4. If it is not visible immediately, log out once and log back in"
