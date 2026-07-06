#!/usr/bin/env bash
# Build AppIcon.icns from the 1024x1024 source PNG.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT_DIR/AppIcon-source.png"
ICONSET="$ROOT_DIR/AppIcon.iconset"
ICNS="$ROOT_DIR/AppIcon.icns"

if [[ ! -f "$SRC" ]]; then
  echo "Missing $SRC — run generate_app_icon.py first." >&2
  exit 1
fi

rm -rf "$ICONSET"
mkdir -p "$ICONSET"

# Standard macOS iconset sizes (Retina @1x / @2x pairs).
sips -z 16 16     "$SRC" --out "$ICONSET/icon_16x16.png"     >/dev/null
sips -z 32 32     "$SRC" --out "$ICONSET/icon_16x16@2x.png"  >/dev/null
sips -z 32 32     "$SRC" --out "$ICONSET/icon_32x32.png"     >/dev/null
sips -z 64 64     "$SRC" --out "$ICONSET/icon_32x32@2x.png"  >/dev/null
sips -z 128 128   "$SRC" --out "$ICONSET/icon_128x128.png"   >/dev/null
sips -z 256 256   "$SRC" --out "$ICONSET/icon_128x128@2x.png" >/dev/null
sips -z 256 256   "$SRC" --out "$ICONSET/icon_256x256.png"   >/dev/null
sips -z 512 512   "$SRC" --out "$ICONSET/icon_256x256@2x.png" >/dev/null
sips -z 512 512   "$SRC" --out "$ICONSET/icon_512x512.png"   >/dev/null
cp "$SRC"              "$ICONSET/icon_512x512@2x.png"

if ! iconutil --convert icns --output "$ICNS" "$ICONSET"; then
  python3 "$ROOT_DIR/script/build_app_icon_icns.py" "$SRC" "$ICNS"
fi
rm -rf "$ICONSET"
echo "Wrote $ICNS"
