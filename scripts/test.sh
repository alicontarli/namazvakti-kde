#!/usr/bin/env bash
set -e

CDW="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$CDW"

RUNNER=""
for path in "/usr/lib/qt6/bin/qmltestrunner" "/usr/bin/qmltestrunner" "/usr/bin/qml6testrunner"; do
    if [ -x "$path" ]; then
        RUNNER="$path"
        break
    fi
done

if [ -z "$RUNNER" ]; then
    echo "Error: qmltestrunner not found!"
    exit 1
fi

echo "Running QML tests with: $RUNNER"
"$RUNNER" -input tests/tst_namazvakti.qml
