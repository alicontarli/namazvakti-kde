#!/usr/bin/env bash
set -e

echo "Uninstalling Namaz Vakti KDE..."

if kpackagetool6 --type Plasma/Applet --list | grep -q "com.local.namazvakti"; then
    kpackagetool6 --type Plasma/Applet --remove com.local.namazvakti
    echo "Removed successfully."
else
    echo "Not installed."
fi
