import AppKit

// MARK: - 在 VS Code 中打开

/// 在 VS Code 中打开文件/目录
public final class OpenInVSCodeAction: FinderAction {
    public let id = "editor.vscode"
    public let title = "在 VS Code 中打开"
    public let icon: NSImage? = NSImage(systemSymbolName: "curlybraces.square", accessibilityDescription: "VS Code")
    public let category: ActionCategory = .openEditor

    private let bundleId = "com.microsoft.VSCode"

    public init() {}

    public var isAvailable: Bool {
        AppDetector.shared.isAppInstalled(bundleId: bundleId)
    }

    public func execute(with urls: [URL]) throws {
        FileOperationService.shared.openApplication(bundleId: bundleId, with: urls)
    }
}

// MARK: - 在 Cursor 中打开

/// 在 Cursor 中打开文件/目录
public final class OpenInCursorAction: FinderAction {
    public let id = "editor.cursor"
    public let title = "在 Cursor 中打开"
    public let icon: NSImage? = NSImage(systemSymbolName: "curlybraces.square", accessibilityDescription: "Cursor")
    public let category: ActionCategory = .openEditor

    private let bundleId = "com.todesktop.230313mzl4w4u92"

    public init() {}

    public var isAvailable: Bool {
        AppDetector.shared.isAppInstalled(bundleId: bundleId)
    }

    public func execute(with urls: [URL]) throws {
        FileOperationService.shared.openApplication(bundleId: bundleId, with: urls)
    }
}

// MARK: - 在 Sublime Text 中打开

/// 在 Sublime Text 中打开文件/目录
public final class OpenInSublimeAction: FinderAction {
    public let id = "editor.sublime"
    public let title = "在 Sublime Text 中打开"
    public let icon: NSImage? = NSImage(systemSymbolName: "curlybraces.square", accessibilityDescription: "Sublime Text")
    public let category: ActionCategory = .openEditor

    private let bundleId = "com.sublimetext.4"

    public init() {}

    public var isAvailable: Bool {
        AppDetector.shared.isAppInstalled(bundleId: bundleId)
    }

    public func execute(with urls: [URL]) throws {
        FileOperationService.shared.openApplication(bundleId: bundleId, with: urls)
    }
}

// MARK: - 在 Zed 中打开

/// 在 Zed 中打开文件/目录
public final class OpenInZedAction: FinderAction {
    public let id = "editor.zed"
    public let title = "在 Zed 中打开"
    public let icon: NSImage? = NSImage(systemSymbolName: "curlybraces.square", accessibilityDescription: "Zed")
    public let category: ActionCategory = .openEditor

    private let bundleId = "dev.zed.Zed"

    public init() {}

    public var isAvailable: Bool {
        AppDetector.shared.isAppInstalled(bundleId: bundleId)
    }

    public func execute(with urls: [URL]) throws {
        FileOperationService.shared.openApplication(bundleId: bundleId, with: urls)
    }
}
