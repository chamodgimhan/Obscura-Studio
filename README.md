# Obscura Studio

A layered image editor that runs entirely on your computer. No uploads, no account, no internet connection needed.

> Built with Claude by Chamod Gimhan.

<!-- Add a screenshot here: drag an image into this file on GitHub, or use ![Obscura Studio](screenshot.png) -->

## Features

- Layer-based editing: every layer stays editable
- Fonts built in (Inter, Lora, Poppins), plus any font installed on your computer
- Handles large images
- Save projects as `.obscura.zip` (all layers kept) and export PNG, JPEG or WebP
- Autosaves every 45 seconds and offers to restore on the next start
- Works offline, as a browser page or as a standalone Windows program
- Can be driven by Claude to edit images automatically (see [`for-claude/`](for-claude/HOW%20CLAUDE%20USES%20THIS.md))

## Run it

| Platform | How |
|---|---|
| Windows | Double-click `Start Obscura Studio.bat` |
| macOS | Double-click `Start Obscura Studio.command` |
| Linux | Run `./start-obscura-studio.sh` |
| Any browser | Open `obscura-studio.html` |

The launchers open the app in its own window using Microsoft Edge or Google Chrome. Keep the files in the same folder.

## Build the Windows program

The `desktop-app/` folder wraps the editor in Electron so it runs as a real `.exe` with no browser.

1. Install [Node.js](https://nodejs.org) (LTS).
2. Run `desktop-app/Build the app (Windows).bat` (needs internet once, to download Electron).
3. Your program appears in a `Windows app` folder next to it. Copy that folder anywhere, including a flash drive.

A prebuilt version is available under **Releases**.

## Editing through Claude

The `for-claude/` folder lets Claude run the editor without a window and apply edits to your images, for example: "Brighten photo.jpg, crop it square and add the title Summer." Needs Node 18+ and Playwright.

## Testing

See [`TEST_REPORT.md`](TEST_REPORT.md) for the test results.

## Licence

Apache License 2.0. Third-party notices (fonts, Electron) are in [`THIRD-PARTY-NOTICES.txt`](THIRD-PARTY-NOTICES.txt).

Copyright (c) 2026 Chamod Gimhan
