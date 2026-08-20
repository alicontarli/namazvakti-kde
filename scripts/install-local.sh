#!/usr/bin/env bash
set -e

CDW="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$CDW"

echo "Installing Namaz Vakti KDE locally..."

# Check if already installed, if so, upgrade, otherwise install
if kpackagetool6 --type Plasma/Applet --list | grep -q "com.local.namazvakti"; then
    echo "Upgrading existing installation..."
    kpackagetool6 --type Plasma/Applet --upgrade package
else
    echo "Installing new package..."
    kpackagetool6 --type Plasma/Applet --install package
fi

# Install app icon to user icon theme for Plasma widget explorer
mkdir -p ~/.local/share/icons/hicolor/scalable/apps/
cp package/contents/icons/namaz-vakti.svg ~/.local/share/icons/hicolor/scalable/apps/namaz-vakti.svg
cp package/contents/icons/namaz-vakti.svg ~/.local/share/icons/hicolor/scalable/apps/com.local.namazvakti.svg

echo "Installation completed successfully."
