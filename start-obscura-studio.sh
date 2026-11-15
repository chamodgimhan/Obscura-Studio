#!/bin/sh
# Opens Obscura Studio in its own window on Linux. No internet connection is needed.
DIR="$(cd "$(dirname "$0")" && pwd)"
URL="file://$DIR/obscura-studio.html"
for B in google-chrome google-chrome-stable chromium chromium-browser microsoft-edge brave-browser; do
  if command -v "$B" >/dev/null 2>&1; then "$B" --app="$URL" --window-size=1500,950 >/dev/null 2>&1 & exit 0; fi
done
xdg-open "$DIR/obscura-studio.html"
