#!/bin/bash
# Opens Obscura Studio in its own window on macOS. No internet connection is needed.
DIR="$(cd "$(dirname "$0")" && pwd)"
URL="file://$(python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1]))' "$DIR/obscura-studio.html" 2>/dev/null || echo "$DIR/obscura-studio.html")"
for APP in "Google Chrome" "Microsoft Edge" "Chromium" "Brave Browser"; do
  if [ -d "/Applications/$APP.app" ]; then open -na "$APP" --args --app="$URL" --window-size=1500,950; exit 0; fi
done
open "$DIR/obscura-studio.html"
