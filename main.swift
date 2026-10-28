import AppKit
import UniformTypeIdentifiers

// Preserve encoding, BOM, and existing line endings while editing plain text.
struct MarkdownText {
    var text = ""
    var encoding = String.Encoding.utf8
    var prefix = Data()
    var originalText = ""
    var originalData = Data()
    var lineEnding = "\n"

    init() {}
    init(data: Data) throws {
        var bytes = data
        if data.starts(with: [0xEF, 0xBB, 0xBF]) {
            prefix = Data([0xEF, 0xBB, 0xBF]); bytes = data.dropFirst(3)
        } else if data.starts(with: [0xFF, 0xFE]) {
            encoding = .utf16LittleEndian; prefix = Data([0xFF, 0xFE]); bytes = data.dropFirst(2)
        } else if data.starts(with: [0xFE, 0xFF]) {
            encoding = .utf16BigEndian; prefix = Data([0xFE, 0xFF]); bytes = data.dropFirst(2)
        }
        guard let decoded = String(data: bytes, encoding: encoding), !decoded.contains("\0") else {
            throw NSError(domain: "MarkdownQuickEdit", code: 1, userInfo: [NSLocalizedDescriptionKey:
                "This file is not UTF-8 or UTF-16 text. It has not been changed."])
        }
        let withoutCRLF = decoded.replacingOccurrences(of: "\r\n", with: "")
        if decoded.contains("\r\n") && !withoutCRLF.contains("\n") && !withoutCRLF.contains("\r") {
            lineEnding = "\r\n"
        } else if decoded.contains("\r") && !decoded.contains("\n") {
            lineEnding = "\r"
        }
        text = decoded.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
        originalText = text; originalData = data
    }
    func data(for value: String) throws -> Data {
        if value == originalText { return originalData }
        let normalized = value.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
        guard let bytes = normalized.replacingOccurrences(of: "\n", with: lineEnding).data(using: encoding, allowLossyConversion: false) else {
            throw NSError(domain: "MarkdownQuickEdit", code: 2, userInfo: [NSLocalizedDescriptionKey: "The text could not be saved without losing characters."])
        }
        return prefix + bytes
    }
}

final class EditorTextView: NSTextView {
    override func cancelOperation(_ sender: Any?) { window?.performClose(sender) }
}

@objc(MarkdownDocument)
final class MarkdownDocument: NSDocument, NSTextViewDelegate {
    var content = MarkdownText()
    var editor: NSTextView?
    var status: NSTextField?
    override class var autosavesInPlace: Bool { false }
    override var windowNibName: NSNib.Name? { nil }

    override func read(from data: Data, ofType typeName: String) throws {
        content = try MarkdownText(data: data)
        editor?.string = content.text
    }
    override func data(ofType typeName: String) throws -> Data {
        try content.data(for: editor?.string ?? content.text)
    }
    override func updateChangeCount(_ change: NSDocument.ChangeType) {
        super.updateChangeCount(change)
        status?.stringValue = isDocumentEdited ? "Unsaved changes" : "Saved"
    }
    func textDidChange(_ notification: Notification) { updateChangeCount(.changeDone) }

    override func makeWindowControllers() {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 780, height: 560),
                              styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        window.minSize = NSSize(width: 420, height: 280)
        window.tabbingMode = .disallowed
        window.center()
        let root = NSView()
        window.contentView = root
        let scroll = NSScrollView()
        scroll.hasVerticalScroller = true
        scroll.autohidesScrollers = true
        scroll.borderType = .noBorder
        let text = EditorTextView(frame: NSRect(x: 0, y: 0, width: 780, height: 510))
        text.isRichText = false
        text.importsGraphics = false
        text.allowsUndo = true
        text.usesFindBar = true
        text.isAutomaticQuoteSubstitutionEnabled = false
        text.isAutomaticDashSubstitutionEnabled = false
        text.isAutomaticTextReplacementEnabled = false
        text.isAutomaticSpellingCorrectionEnabled = false
        text.isContinuousSpellCheckingEnabled = false
        text.font = NSFont.monospacedSystemFont(ofSize: 15, weight: .regular)
        text.textColor = .textColor
        text.backgroundColor = .textBackgroundColor
        text.textContainerInset = NSSize(width: 20, height: 18)
        text.isVerticallyResizable = true
        text.isHorizontallyResizable = false
        text.autoresizingMask = [.width]
        text.textContainer?.widthTracksTextView = true
        text.textContainer?.containerSize = NSSize(width: 780, height: CGFloat.greatestFiniteMagnitude)
        text.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        text.string = content.text
        text.delegate = self
        text.setAccessibilityLabel("Markdown editor")
        scroll.documentView = text
        editor = text
        let label = NSTextField(labelWithString: fileURL == nil ? "New document" : "Saved")
        label.textColor = .secondaryLabelColor
        label.font = .systemFont(ofSize: 12)
        label.setAccessibilityIdentifier("save-status")
        status = label
        let hint = NSTextField(labelWithString: "⌘S Save   ·   ⌘↩ Save & Close")
        hint.textColor = .secondaryLabelColor
        hint.font = .systemFont(ofSize: 12)
        let save = NSButton(title: "Save", target: self, action: #selector(NSDocument.save(_:)))
        save.bezelStyle = .rounded
        for view in [scroll, label, hint, save] { view.translatesAutoresizingMaskIntoConstraints = false; root.addSubview(view) }
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: root.topAnchor), scroll.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: root.trailingAnchor), scroll.bottomAnchor.constraint(equalTo: root.bottomAnchor, constant: -48),
            label.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 20), label.centerYAnchor.constraint(equalTo: save.centerYAnchor),
            save.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -16), save.bottomAnchor.constraint(equalTo: root.bottomAnchor, constant: -10),
            hint.trailingAnchor.constraint(equalTo: save.leadingAnchor, constant: -16), hint.centerYAnchor.constraint(equalTo: save.centerYAnchor),
            hint.leadingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: 12)
        ])
        let controller = NSWindowController(window: window)
        addWindowController(controller)
        window.makeFirstResponder(text)
    }
    @objc func saveAndClose(_ sender: Any?) {
        save(withDelegate: self, didSave: #selector(didSaveForClose(_:didSave:contextInfo:)), contextInfo: nil)
    }
    @objc func didSaveForClose(_ document: NSDocument, didSave: Bool, contextInfo: UnsafeMutableRawPointer?) {
        if didSave { close() }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}

func menuItem(_ title: String, _ action: Selector?, _ key: String = "") -> NSMenuItem {
    NSMenuItem(title: title, action: action, keyEquivalent: key)
}

func makeMenus() {
    let bar = NSMenu()
    func submenu(_ title: String, _ items: [NSMenuItem]) {
        let parent = NSMenuItem(); let menu = NSMenu(title: title)
        for item in items { menu.addItem(item) }
        parent.submenu = menu; bar.addItem(parent)
    }
    submenu("Markdown Quick Edit", [menuItem("About Markdown Quick Edit", #selector(NSApplication.orderFrontStandardAboutPanel(_:))), .separator(),
        menuItem("Hide Markdown Quick Edit", #selector(NSApplication.hide(_:)), "h"), .separator(),
        menuItem("Quit Markdown Quick Edit", #selector(NSApplication.terminate(_:)), "q")])
    let saveAs = menuItem("Save As…", #selector(NSDocument.saveAs(_:)), "S")
    submenu("File", [menuItem("New", #selector(NSDocumentController.newDocument(_:)), "n"),
        menuItem("Open…", #selector(NSDocumentController.openDocument(_:)), "o"), .separator(),
        menuItem("Save", #selector(NSDocument.save(_:)), "s"), saveAs,
        menuItem("Save & Close", #selector(MarkdownDocument.saveAndClose(_:)), "\r"), .separator(),
        menuItem("Close", #selector(NSWindow.performClose(_:)), "w")])
    let find = menuItem("Find…", #selector(NSTextView.performFindPanelAction(_:)), "f")
    find.tag = NSTextFinder.Action.showFindInterface.rawValue
    submenu("Edit", [menuItem("Undo", Selector(("undo:")), "z"), menuItem("Redo", Selector(("redo:")), "Z"), .separator(),
        menuItem("Cut", #selector(NSText.cut(_:)), "x"), menuItem("Copy", #selector(NSText.copy(_:)), "c"),
        menuItem("Paste", #selector(NSText.paste(_:)), "v"), menuItem("Select All", #selector(NSText.selectAll(_:)), "a"), .separator(), find])
    submenu("Window", [menuItem("Minimize", #selector(NSWindow.miniaturize(_:)), "m"), menuItem("Zoom", #selector(NSWindow.zoom(_:)))])
    NSApp.mainMenu = bar
    NSApp.windowsMenu = bar.items.last?.submenu
}

if CommandLine.arguments.contains("--self-test") {
    let samples = [Data("# Hello\n繁體中文 😀\n".utf8), Data([0xEF,0xBB,0xBF]) + Data("# BOM\r\nText\r\n".utf8),
                   Data([0xFF,0xFE]) + "# UTF16\r\n中文\r\n".data(using: .utf16LittleEndian)!, Data()]
    for sample in samples {
        let decoded = try MarkdownText(data: sample)
        let roundTrip = try decoded.data(for: decoded.text)
        precondition(roundTrip == sample, "Untouched bytes must round-trip")
        let changed = try decoded.data(for: decoded.text + "Added 中文\n")
        let reread = try MarkdownText(data: changed)
        precondition(reread.text == decoded.text + "Added 中文\n")
        precondition(reread.encoding == decoded.encoding)
        precondition(changed.starts(with: decoded.prefix))
    }
    do { _ = try MarkdownText(data: Data([0xFF, 0x00, 0x80])); fatalError("Invalid bytes accepted") } catch {}
    print("PASS: UTF-8, BOM, UTF-16, Chinese, emoji, CRLF, empty files, invalid-data rejection")
} else {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.regular)
    _ = NSDocumentController.shared
    makeMenus()
    app.activate(ignoringOtherApps: true)
    app.run()
}
