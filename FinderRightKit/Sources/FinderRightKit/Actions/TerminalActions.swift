import AppKit

// MARK: - 在 Terminal.app 中打开

/// 在 Terminal.app 中打开目录
public final class OpenInTerminalAction: FinderAction {
    public let id = "terminal.apple"
    public let title = "在终端中打开"
    public let icon: NSImage? = NSImage(systemSymbolName: "terminal", accessibilityDescription: "Terminal")
    public let category: ActionCategory = .openTerminal

    private let bundleId = "com.apple.Terminal"

    public init() {}

    public var isAvailable: Bool {
        AppDetector.shared.isAppInstalled(bundleId: bundleId)
    }

    public func execute(with urls: [URL]) throws {
        guard let url = urls.first else { return }
        let directory = url.hasDirectoryPath ? url : url.deletingLastPathComponent()
        FileOperationService.shared.openApplication(bundleId: bundleId, with: [directory])
    }
}

// MARK: - 在 iTerm2 中打开

/// 在 iTerm2 中打开目录
public final class OpenInITermAction: FinderAction {
    public let id = "terminal.iterm2"
    public let title = "在 iTerm2 中打开"
    public let icon: NSImage? = NSImage(systemSymbolName: "terminal", accessibilityDescription: "iTerm2")
    public let category: ActionCategory = .openTerminal

    private let bundleId = "com.googlecode.iterm2"

    public init() {}

    public var isAvailable: Bool {
        AppDetector.shared.isAppInstalled(bundleId: bundleId)
    }

    public func execute(with urls: [URL]) throws {
        guard let url = urls.first else { return }
        let directory = url.hasDirectoryPath ? url : url.deletingLastPathComponent()
        let escapedPath = directory.path.replacingOccurrences(of: "\"", with: "\\\"")

        let script = """
        tell application "iTerm"
            activate
            if (count of windows) = 0 then
                create window with default profile
            end if
            tell current session of current window
                write text "cd \\"\(escapedPath)\\""
            end tell
        end tell
        """
        try FileOperationService.shared.runAppleScript(script)
    }
}

// MARK: - 在 Warp 中打开

/// 在 Warp 终端中打开目录
public final class OpenInWarpAction: FinderAction {
    public let id = "terminal.warp"
    public let title = "在 Warp 中打开"
    public let icon: NSImage? = NSImage(systemSymbolName: "terminal", accessibilityDescription: "Warp")
    public let category: ActionCategory = .openTerminal

    private let bundleId = "dev.warp.Warp-Stable"

    public init() {}

    public var isAvailable: Bool {
        AppDetector.shared.isAppInstalled(bundleId: bundleId)
    }

    public func execute(with urls: [URL]) throws {
        guard let url = urls.first else { return }
        let directory = url.hasDirectoryPath ? url : url.deletingLastPathComponent()
        FileOperationService.shared.openApplication(bundleId: bundleId, with: [directory])
    }
}
