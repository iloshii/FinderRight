import AppKit

// MARK: - 文件操作错误

/// 文件操作错误类型
public enum FileOperationError: LocalizedError {
    case fileAlreadyExists(String)
    case fileNotFound(String)
    case operationFailed(String)
    case scriptError(String)
    case processError(String, Int32)

    public var errorDescription: String? {
        switch self {
        case .fileAlreadyExists(let path):
            return "文件已存在: \(path)"
        case .fileNotFound(let path):
            return "文件未找到: \(path)"
        case .operationFailed(let message):
            return "操作失败: \(message)"
        case .scriptError(let message):
            return "脚本错误: \(message)"
        case .processError(let message, let code):
            return "进程错误 (\(code)): \(message)"
        }
    }
}

// MARK: - 文件操作服务

/// 文件操作工具类
public final class FileOperationService {

    public static let shared = FileOperationService()

    private init() {}

    // MARK: - 创建文件

    /// 在指定目录创建文件
    /// - Parameters:
    ///   - directoryURL: 目标目录
    ///   - name: 文件名（不含扩展名）
    ///   - fileExtension: 文件扩展名
    ///   - content: 文件内容
    /// - Returns: 创建的文件 URL
    @discardableResult
    public func createFile(at directoryURL: URL, name: String, extension fileExtension: String, content: String = "") throws -> URL {
        let fileName = fileExtension.isEmpty ? name : "\(name).\(fileExtension)"
        let fileURL = directoryURL.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            throw FileOperationError.fileAlreadyExists(fileURL.path)
        }

        guard let data = content.data(using: .utf8) else {
            throw FileOperationError.operationFailed("无法编码文件内容")
        }

        try data.write(to: fileURL)
        return fileURL
    }

    // MARK: - 剪贴板操作

    /// 复制字符串到剪贴板
    public func copyToClipboard(_ string: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
    }

    // MARK: - 打开应用

    /// 使用指定应用打开文件/目录
    public func openApplication(bundleId: String, with urls: [URL]) {
        let configuration = NSWorkspace.OpenConfiguration()
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
            NSWorkspace.shared.open(urls, withApplicationAt: appURL, configuration: configuration)
        }
    }

    // MARK: - AppleScript

    /// 执行 AppleScript
    @discardableResult
    public func runAppleScript(_ source: String) throws -> String? {
        var error: NSDictionary?
        let script = NSAppleScript(source: source)
        let result = script?.executeAndReturnError(&error)

        if let error = error {
            let message = error[NSAppleScript.errorMessage] as? String ?? "未知错误"
            throw FileOperationError.scriptError(message)
        }

        return result?.stringValue
    }

    // MARK: - 切换隐藏文件

    /// 切换 Finder 显示隐藏文件
    public func toggleHiddenFiles() throws {
        let script = """
        set currentState to do shell script "defaults read com.apple.finder AppleShowAllFiles"
        if currentState is "1" or currentState is "YES" or currentState is "true" then
            do shell script "defaults write com.apple.finder AppleShowAllFiles -bool false"
        else
            do shell script "defaults write com.apple.finder AppleShowAllFiles -bool true"
        end if
        do shell script "killall Finder"
        """
        try runAppleScript(script)
    }

    // MARK: - 压缩文件

    /// 压缩文件为 ZIP
    /// - Parameter urls: 要压缩的文件/目录 URL 列表
    /// - Returns: 生成的 ZIP 文件 URL
    @discardableResult
    public func compressFiles(_ urls: [URL]) throws -> URL {
        guard let firstURL = urls.first else {
            throw FileOperationError.operationFailed("没有选择文件")
        }

        let directoryURL = firstURL.deletingLastPathComponent()
        let archiveName: String
        if urls.count == 1 {
            archiveName = firstURL.deletingPathExtension().lastPathComponent + ".zip"
        } else {
            archiveName = "Archive.zip"
        }
        let archiveURL = directoryURL.appendingPathComponent(archiveName)

        let fileNames = urls.map { $0.lastPathComponent }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        process.arguments = ["-r", archiveURL.path] + fileNames
        process.currentDirectoryURL = directoryURL

        let errorPipe = Pipe()
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "未知错误"
            throw FileOperationError.processError(errorMessage, process.terminationStatus)
        }

        return archiveURL
    }

    // MARK: - 解压文件

    /// 解压文件
    /// - Parameters:
    ///   - url: 压缩文件 URL
    ///   - toFolder: 是否解压到同名文件夹
    /// - Returns: 解压目标目录 URL
    @discardableResult
    public func decompressFile(_ url: URL, toFolder: Bool) throws -> URL {
        let directoryURL = url.deletingLastPathComponent()
        let destinationURL: URL

        if toFolder {
            let folderName = url.deletingPathExtension().lastPathComponent
            destinationURL = directoryURL.appendingPathComponent(folderName)
            try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true)
        } else {
            destinationURL = directoryURL
        }

        let fileExtension = url.pathExtension.lowercased()

        let process = Process()
        let errorPipe = Pipe()
        process.standardError = errorPipe

        if fileExtension == "zip" {
            process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
            process.arguments = ["-o", url.path, "-d", destinationURL.path]
        } else if fileExtension == "tar" || fileExtension == "gz" || fileExtension == "tgz" || fileExtension == "bz2" || fileExtension == "xz" {
            process.executableURL = URL(fileURLWithPath: "/usr/bin/tar")
            process.arguments = ["-xf", url.path, "-C", destinationURL.path]
        } else {
            throw FileOperationError.operationFailed("不支持的压缩格式: \(fileExtension)")
        }

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "未知错误"
            throw FileOperationError.processError(errorMessage, process.terminationStatus)
        }

        return destinationURL
    }

    // MARK: - 运行 Shell 命令

    /// 运行 shell 命令并返回输出
    @discardableResult
    public func runShellCommand(_ command: String, arguments: [String] = [], currentDirectory: URL? = nil) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments
        if let currentDirectory = currentDirectory {
            process.currentDirectoryURL = currentDirectory
        }

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        if process.terminationStatus != 0 {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "未知错误"
            throw FileOperationError.processError(errorMessage, process.terminationStatus)
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: outputData, encoding: .utf8) ?? ""
    }
}
