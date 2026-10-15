#!/usr/bin/env bash
# Builds the Flutter web game and copies it into vercel-site/ (macOS / Linux / Git Bash).
# Run from anywhere:   bash tools/build_vercel_site.sh
set -euo pipefail
cd "$(dirname "$0")/.."

flutter pub get
flutter build web --release
[ -f build/web/index.html ] || { echo "Build failed: build/web/index.html not found"; exit 1; }

mkdir -p vercel-site
find vercel-site -mindepth 1 -maxdepth 1 ! -name README.md -exec rm -rf {} +
cp -R build/web/. vercel-site/

echo
echo "Done. vercel-site/ now contains the compiled game."
echo "Next: git add vercel-site && git commit -m 'Update web build' && git push"
