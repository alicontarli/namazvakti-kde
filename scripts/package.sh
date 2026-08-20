#!/usr/bin/env bash
set -e

CDW="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$CDW"

echo "Verifying project files..."
if [ ! -f "package/metadata.json" ]; then
    echo "Error: package/metadata.json not found!"
    exit 1
fi

LINTER="/usr/lib/qt6/bin/qmllint"
if [ -x "$LINTER" ]; then
    echo "Running qmllint..."
    find package/contents/ui/ -name "*.qml" -exec "$LINTER" {} + || echo "qmllint warning (non-fatal)"
else
    echo "qmllint not found, skipping linting."
fi

echo "Running tests..."
./scripts/test.sh

VERSION=$(python3 -c "import json; print(json.load(open('package/metadata.json'))['KPlugin']['Version'])")
echo "Packaging version: $VERSION"

mkdir -p dist
rm -f dist/*

cd package
python3 -c "import zipfile, os; zipf = zipfile.ZipFile('../dist/namaz-vakti-kde-${VERSION}.plasmoid', 'w', zipfile.ZIP_DEFLATED); [zipf.write(os.path.join(r, f), os.path.relpath(os.path.join(r, f), '.')) for r, d, files in os.walk('.') for f in files]"
cd ..
cp "dist/namaz-vakti-kde-${VERSION}.plasmoid" "dist/namaz-vakti-kde-${VERSION}.zip"
rsvg-convert -w 512 -h 512 package/contents/icons/namaz-vakti.svg -o dist/logo.png
cp dist/logo.png ./logo.png

echo "Package created successfully at:"
echo "  dist/namaz-vakti-kde-${VERSION}.plasmoid"
echo "  dist/namaz-vakti-kde-${VERSION}.zip"
echo "  dist/logo.png"
echo "  logo.png"
