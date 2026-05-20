import AppKit

// MARK: - 切换隐藏文件显示

/// 切换 Finder 显示/隐藏隐藏文件
public final class ToggleHiddenFilesAction: FinderAction {
    public let id = "visibility.hidden"
    public let title = "显示/隐藏 隐藏文件"
    public let icon: NSImage? = NSImage(systemSymbolName: "eye.slash", accessibilityDescription: "Toggle Hidden Files")
    public let category: ActionCategory = .visibility

    public init() {}

    public func execute(with urls: [URL]) throws {
        // 读取当前状态
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        process.arguments = ["read", "com.apple.finder", "AppleShowAllFiles"]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = Pipe() // 忽略 stderr

        try process.run()
        process.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let currentlyShowing = (output == "1" || output.lowercased() == "yes" || output.lowercased() == "true")
        let newValue = currentlyShowing ? "false" : "true"

        // 设置新状态
        let writeProcess = Process()
        writeProcess.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        writeProcess.arguments = ["write", "com.apple.finder", "AppleShowAllFiles", "-bool", newValue]

        try writeProcess.run()
        writeProcess.waitUntilExit()

        // 重启 Finder
        let killProcess = Process()
        killProcess.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
        killProcess.arguments = ["Finder"]

        try killProcess.run()
        killProcess.waitUntilExit()

        // 更新 SharedConfig
        SharedConfig.shared.showHiddenFiles = !currentlyShowing
    }
}
