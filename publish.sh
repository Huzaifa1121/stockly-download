#!/bin/bash
# Publish the website and the download. Run from inside this folder:
#   bash publish.sh
# It needs the GitHub CLI signed in (gh auth status).
set -e
cd "$(dirname "$0")"

REPO="Huzaifa1121/stockly-download"
ZIP="$HOME/Desktop/stockly-2026-10-04.zip"

# The CLI knows two accounts. Everything here belongs to Huzaifa1121, so use
# that one, and put the other back afterwards.
PREVIOUS="$(gh api user --jq .login 2>/dev/null || true)"
gh auth switch -u Huzaifa1121
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
git commit -q -m "Website and install guide" || true
git push -u origin main

# 3. Turn on GitHub Pages, served from the main branch.
gh api -X POST "repos/$REPO/pages" -f 'source[branch]=main' -f 'source[path]=/' >/dev/null 2>&1 || true

# 4. The first release. The asset must be named stockly.zip so the
#    "latest" link on the website never changes.
cp "$ZIP" /tmp/stockly.zip
gh release create v0.1.0 /tmp/stockly.zip --repo "$REPO" --title "Stockly 0.1.0" \
  --notes "First public download. Unzip, move the folder to Documents, double-click Start Stockly."
rm -f /tmp/stockly.zip

echo ""
echo "Website:  https://huzaifa1121.github.io/stockly-download/   (live in a minute or two)"
echo "Download: https://github.com/$REPO/releases/latest/download/stockly.zip"
