#!/bin/bash
# Stockly for Mac — install, or update, with one line in Terminal:
#
#   /bin/bash -c "$(curl -fsSL https://huzaifa1121.github.io/stockly-download/install.sh)"
#
# Why a line in Terminal instead of a downloaded file: macOS blocks files a
# browser downloads ("Apple could not verify…") unless they are signed by a
# paid Apple developer account. Files fetched by curl are not flagged, so
# nothing here is blocked and no one has to go into System Settings.
#
# Installs into ~/Stockly (not Documents: macOS stops background jobs reading
# Documents, which broke starting at login), adds Stockly to Applications,
# and runs the usual setup. Run it again to update: the shop's data, settings
# and licence are kept.
set -e

APP_DIR="$HOME/Stockly"
MAC_APP="$HOME/Applications/Stockly.app"
AGENT="$HOME/Library/LaunchAgents/com.stockly.app.plist"
ZIP_URL="${STOCKLY_ZIP_URL:-https://github.com/Huzaifa1121/stockly-download/releases/latest/download/stockly.zip}"

say() { printf "\n  %s\n" "$*"; }
fail() { printf "\n  %s\n\n" "$*"; exit 1; }

[ "$(uname)" = "Darwin" ] || fail "This installer is for a Mac. On Windows, use the download on the website."

running_port() {
  for p in 3000 3001 3002 3003 3004 3005; do
    if curl -fsS --max-time 1 "http://localhost:$p/api/health" 2>/dev/null | grep -q '"app":"stockly"'; then
      echo "$p"; return 0
    fi
  done
  return 1
}

echo ""
echo "  Stockly — installing on this Mac"
echo "  ================================"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

say "Downloading Stockly…"
case "$ZIP_URL" in
  /*) cp "$ZIP_URL" "$TMP/stockly.zip" ;;     # a local zip, for testing
  *) curl -fL --progress-bar "$ZIP_URL" -o "$TMP/stockly.zip" || fail "Could not download Stockly. Is this Mac connected to the internet?" ;;
esac
unzip -q "$TMP/stockly.zip" -d "$TMP/x"
SRC="$(find "$TMP/x" -mindepth 1 -maxdepth 1 -type d | head -1)"
[ -f "$SRC/setup.command" ] || fail "The download looks damaged. Please try again."

if [ -d "$APP_DIR" ]; then
  say "Updating Stockly in $APP_DIR — your shop's records are kept."
  # Stop the running copy so its files can be replaced.
  [ -f "$AGENT" ] && launchctl unload "$AGENT" >/dev/null 2>&1 || true
  if p="$(running_port)"; then
    for pid in $(lsof -nP -iTCP:"$p" -sTCP:LISTEN -t 2>/dev/null); do kill "$pid" 2>/dev/null || true; done
    sleep 2
  fi
  # Replace the program, never the shop: data, settings and licence stay.
  rsync -a --delete \
    --exclude "/data" --exclude "/.env" --exclude "/licence.key" \
    --exclude "/node_modules" --exclude "/.next" --exclude "/logs" \
    "$SRC/" "$APP_DIR/"
else
  say "Installing Stockly in $APP_DIR"
  mv "$SRC" "$APP_DIR"
fi
chmod +x "$APP_DIR"/*.command 2>/dev/null || true

# --------------------------------------------------------------- the Mac app
# A small app in Applications (and Launchpad) with Stockly's icon. It opens
# Stockly, starting it first if it is not running.
say "Adding Stockly to Applications…"
mkdir -p "$MAC_APP/Contents/MacOS" "$MAC_APP/Contents/Resources"
cat > "$MAC_APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>Stockly</string>
  <key>CFBundleDisplayName</key><string>Stockly</string>
  <key>CFBundleIdentifier</key><string>com.stockly.launcher</string>
  <key>CFBundleExecutable</key><string>stockly</string>
  <key>CFBundleIconFile</key><string>Stockly</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>LSMinimumSystemVersion</key><string>11.0</string>
</dict>
</plist>
PLIST
cat > "$MAC_APP/Contents/MacOS/stockly" <<'LAUNCHER'
#!/bin/bash
# Open Stockly. Start it first if it is not running.
DIR="$HOME/Stockly"
AGENT="$HOME/Library/LaunchAgents/com.stockly.app.plist"
running_port() {
  for p in 3000 3001 3002 3003 3004 3005; do
    curl -fsS --max-time 1 "http://localhost:$p/api/health" 2>/dev/null | grep -q '"app":"stockly"' && { echo "$p"; return 0; }
  done
  return 1
}
if p="$(running_port)"; then open "http://localhost:$p"; exit 0; fi
if [ -f "$AGENT" ]; then
  # Set to start by itself: ask macOS to start it now.
  launchctl kickstart -k "gui/$(id -u)/com.stockly.app" >/dev/null 2>&1 || launchctl load -w "$AGENT" >/dev/null 2>&1
else
  # Not set to start by itself: run it in a Terminal window, as Start Stockly does.
  open -a Terminal "$DIR/Start Stockly.command"
  exit 0
fi
for i in $(seq 1 60); do
  if p="$(running_port)"; then open "http://localhost:$p"; exit 0; fi
  sleep 1
done
osascript -e 'display alert "Stockly did not start" message "Open the Stockly folder in your home folder and double-click Start Stockly to see why."' >/dev/null 2>&1
LAUNCHER
chmod +x "$MAC_APP/Contents/MacOS/stockly"
# The icon, made from Stockly's own artwork with the Mac's built-in tools.
ICON_SRC="$APP_DIR/public/icon-512.png"
if [ -f "$ICON_SRC" ]; then
  SET="$TMP/Stockly.iconset"; mkdir -p "$SET"
  for s in 16 32 128 256 512; do
    sips -z $s $s "$ICON_SRC" --out "$SET/icon_${s}x${s}.png" >/dev/null 2>&1
    d=$((s * 2)); sips -z $d $d "$ICON_SRC" --out "$SET/icon_${s}x${s}@2x.png" >/dev/null 2>&1
  done
  iconutil -c icns "$SET" -o "$MAC_APP/Contents/Resources/Stockly.icns" >/dev/null 2>&1 || true
fi
touch "$MAC_APP"

# --------------------------------------------------------------- setup
# Installs Node if needed, prepares the data file, builds, and offers to start
# Stockly by itself whenever the Mac turns on.
cd "$APP_DIR"
bash ./setup.command --from-launcher

# Set to start by itself? Make sure macOS has the (possibly updated) job loaded.
if [ -f "$AGENT" ]; then
  launchctl unload "$AGENT" >/dev/null 2>&1 || true
  launchctl load -w "$AGENT" >/dev/null 2>&1 || true
fi

say "Stockly is installed."
echo "  Open it any time from Applications or Launchpad: look for Stockly."
echo ""

# Open it now.
if [ -f "$AGENT" ]; then
  for i in $(seq 1 90); do
    if p="$(running_port)"; then open "http://localhost:$p"; echo "  Opening Stockly…"; echo ""; exit 0; fi
    sleep 1
  done
  echo "  Stockly is still starting. Open it from Applications in a minute."
  echo ""
else
  exec bash ./start.command
fi
