# Markdown Quick Edit

English · [繁體中文](README.zh-TW.md) · [简体中文](README.zh-CN.md)

**Open a Markdown file. Make a quick change. Save and get back to work.**

Markdown Quick Edit is a tiny native macOS app for the moments when you only need to update a note, fix a line, or add a thought. One compact window, editable Markdown source, and a Save button. Built with Swift and AppKit, with no third-party dependencies, accounts, network requests, or background service. The original Apple Silicon app bundle occupied approximately 144 KB on disk; build sizes vary.

## Get started

Requires macOS and Apple's Command Line Tools (`xcode-select --install` if needed). The deployment target is macOS 13 or later. The app has been tested on Apple Silicon; the build script also selects an Intel target on Intel Macs, but that configuration has not been tested.

```sh
git clone https://github.com/HyperfocuSam/markdown-quick-edit.git
cd markdown-quick-edit
chmod +x build.sh
./build.sh --install
```

The script compiles, signs locally, runs its self-tests, and installs into `~/Applications/Markdown Quick Edit.app`. If an installed copy already exists, it leaves that copy alone. Quit the old app and replace it in Finder with the new app from `dist/`.

For a build without installation, use `./build.sh`. The output is `dist/Markdown Quick Edit.app`. This project is distributed as source; local builds are ad-hoc signed, not Developer ID signed or Apple-notarized.

## Open Markdown files directly

In Finder, select a `.md` file and choose **Get Info → Open with → Markdown Quick Edit → Change All…**. Then double-click a Markdown file to edit it. Repeat for another extension if macOS treats it separately. The app declares `.md`, `.markdown`, and `.mdown` support. Installation does not change your default editor automatically.

You can also launch the app and choose **File → Open…**, or drag a Markdown file onto the app.

## A small window for quick changes

| Action | Shortcut |
| --- | --- |
| Save | ⌘S, or the Save button |
| Save and close | ⌘Return |
| Close | ⌘W |
| Find | ⌘F |
| Open a file | ⌘O |
| New document | ⌘N |
| Save As | ⇧⌘S |
| Undo / redo | ⌘Z / ⇧⌘Z |

Closing a document with unsaved changes prompts you to save, discard, or cancel. The app quits when its last window closes. The editor displays Markdown source rather than a rendered preview. The app interface is currently English; this documentation is available in three languages.

## Text handling

UTF-8 and UTF-16 with a byte-order mark are supported, including Chinese and emoji. Existing byte-order marks and consistent LF, CRLF, or CR line endings are preserved. Saving unchanged text preserves the original bytes. Editing a file with mixed line endings normalizes its line endings to LF. Unsupported or invalid encodings are rejected instead of silently losing characters.

Smart quotes, smart dashes, automatic text replacement, and spelling correction are disabled. Saves are explicit through Apple's [NSDocument](https://developer.apple.com/documentation/appkit/nsdocument/) infrastructure; the app does not enable autosave in place.

## Build and verification

Every build runs the embedded encoding self-test. To run it again:

```sh
"dist/Markdown Quick Edit.app/Contents/MacOS/MarkdownQuickEdit" --self-test
```

The original app was exercised through its native interface: opening a file, editing, saving with both the button and ⌘S, reopening through a Finder double-click, cancelling the unsaved-close prompt, and using Save and Close. Disk reads confirmed Unicode content and CRLF preservation. External-edit conflicts, crash recovery, and very large files have not been separately tested.

## Contribute and share

Issues, small focused pull requests, and documentation translations are welcome. Please describe the macOS version, hardware architecture, steps to reproduce, and expected behaviour when reporting a problem. Use a small non-sensitive sample if a particular file triggers it.

Keep the app focused on quick Markdown edits and keep the three READMEs aligned when behaviour changes. You are welcome to use, modify, and share the project under the [MIT license](LICENSE).

Created by [Sam Wong](https://github.com/HyperfocuSam).
