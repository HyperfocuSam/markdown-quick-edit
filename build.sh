#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

if [[ "${1:-}" != "" && "${1:-}" != "--install" ]] || (( $# > 1 )); then
  echo "Usage: ./build.sh [--install]" >&2
  exit 2
fi
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Markdown Quick Edit requires macOS." >&2
  exit 1
fi

APP="dist/Markdown Quick Edit.app"
ARCH="$(uname -m)"
case "$ARCH" in
  arm64|x86_64) ;;
  *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
xcrun swiftc -O -target "${ARCH}-apple-macosx13.0" main.swift \
  -o "$APP/Contents/MacOS/MarkdownQuickEdit" \
  -framework AppKit -framework UniformTypeIdentifiers
cp Info.plist "$APP/Contents/Info.plist"
codesign --force --sign - "$APP"
codesign --verify --strict "$APP"
plutil -lint "$APP/Contents/Info.plist"
"$APP/Contents/MacOS/MarkdownQuickEdit" --self-test
echo "Built: $PWD/$APP ($ARCH)"

if [[ "${1:-}" == "--install" ]]; then
  DEST="$HOME/Applications/Markdown Quick Edit.app"
  if [[ -e "$DEST" ]]; then
    echo "An app already exists at $DEST. Quit it, then replace it in Finder using the newly built app." >&2
    exit 1
  fi
  mkdir -p "$HOME/Applications"
  ditto "$APP" "$DEST"
  /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$DEST"
  echo "Installed: $DEST"
fi
