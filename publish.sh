#!/bin/bash
# Publish the website and a new download. Run from anywhere:
#   bash ~/Documents/stockly-download/publish.sh v0.1.1
# Make the zip first, in the stockly folder:  npm run pack
set -e
cd "$(dirname "$0")"

REPO="Huzaifa1121/stockly-download"
VERSION="${1:?Give a version, for example: bash publish.sh v0.1.1}"
APP="$HOME/Documents/stockly"

# Build a fresh zip from the latest committed code, into a folder this
# script can read. (macOS stops Terminal from listing the Desktop.)
PACK_DIR="$(mktemp -d)"
echo "Packing Stockly from ${APP}..."
( cd "$APP" && STOCKLY_PACK_DIR="$PACK_DIR" npm run --silent pack >/dev/null )
ZIP="$(ls "$PACK_DIR"/stockly-*.zip 2>/dev/null | head -1)"
[ -n "$ZIP" ] || { echo "Packing failed. Run npm run pack in $APP to see why."; exit 1; }
echo "Publishing $(basename "$ZIP") as $VERSION"

# The CLI knows two accounts. Everything here belongs to Huzaifa1121, so use
# that one, and put the other back afterwards.
PREVIOUS="$(gh api user --jq .login 2>/dev/null || true)"
gh auth switch -u Huzaifa1121 >/dev/null
trap '[ -n "$PREVIOUS" ] && gh auth switch -u "$PREVIOUS" >/dev/null 2>&1' EXIT

# 1. The public repository that holds the site and the downloads.
if ! gh repo view "$REPO" >/dev/null 2>&1; then
  gh repo create "$REPO" --public --description "Download Stockly: inventory and point-of-sale for small shops. Works offline, data stays in the shop."
fi

# 2. Push the site.
if [ ! -d .git ]; then
  git init -q -b main
  git remote add origin "https://github.com/$REPO.git"
fi
git add -A
git commit -q -m "Website for $VERSION" || true
git push -q -u origin main

# 3. GitHub Pages, served from the main branch (does nothing if already on).
gh api -X POST "repos/$REPO/pages" -f 'source[branch]=main' -f 'source[path]=/' >/dev/null 2>&1 || true

# 4. The release. The file must be called stockly.zip so the "latest" link
#    on the website never changes.
TMP="$(mktemp -d)"
cp "$ZIP" "$TMP/stockly.zip"
gh release create "$VERSION" "$TMP/stockly.zip" --repo "$REPO" --title "Stockly $VERSION" \
  --notes "${NOTES:-Unzip, move the folder to Documents, double-click Start Stockly.}"
rm -rf "$TMP" "$PACK_DIR"

echo ""
echo "Website:  https://huzaifa1121.github.io/stockly-download/"
echo "Download: https://github.com/$REPO/releases/latest/download/stockly.zip"
