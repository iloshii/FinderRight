import AppKit

// MARK: - 复制 POSIX 路径

/// 复制文件的 POSIX 路径
public final class CopyPOSIXPathAction: FinderAction {
    public let id = "copypath.posix"
    public let title = "复制 POSIX 路径"
    public let icon: NSImage? = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Copy Path")
    public let category: ActionCategory = .copyPath

    public init() {}

    public func execute(with urls: [URL]) throws {
        let paths = urls.map { $0.path }
        let result = paths.joined(separator: "\n")
        FileOperationService.shared.copyToClipboard(result)
    }
}

// MARK: - 复制 file:// URL

/// 复制 file:// URL 格式路径
public final class CopyFileURLAction: FinderAction {
    public let id = "copypath.fileurl"
    public let title = "复制文件 URL"
    public let icon: NSImage? = NSImage(systemSymbolName: "link", accessibilityDescription: "Copy URL")
    public let category: ActionCategory = .copyPath

    public init() {}

    public func execute(with urls: [URL]) throws {
        let urlStrings = urls.map { $0.absoluteString }
        let result = urlStrings.joined(separator: "\n")
        FileOperationService.shared.copyToClipboard(result)
    }
}

// MARK: - 复制文件名（带扩展名）

/// 复制文件名（包含扩展名）
public final class CopyFileNameAction: FinderAction {
    public let id = "copypath.filename"
    public let title = "复制文件名"
    public let icon: NSImage? = NSImage(systemSymbolName: "doc.text", accessibilityDescription: "Copy Filename")
    public let category: ActionCategory = .copyPath

    public init() {}

    public func execute(with urls: [URL]) throws {
        let names = urls.map { $0.lastPathComponent }
        let result = names.joined(separator: "\n")
        FileOperationService.shared.copyToClipboard(result)
    }
}

// MARK: - 复制文件名（不带扩展名）

/// 复制文件名（不包含扩展名）
public final class CopyFileNameWithoutExtAction: FinderAction {
    public let id = "copypath.filename_noext"
    public let title = "复制文件名（无扩展名）"
    public let icon: NSImage? = NSImage(systemSymbolName: "doc", accessibilityDescription: "Copy Filename Without Extension")
    public let category: ActionCategory = .copyPath

    public init() {}

    public func execute(with urls: [URL]) throws {
        let names = urls.map { $0.deletingPathExtension().lastPathComponent }
        let result = names.joined(separator: "\n")
        FileOperationService.shared.copyToClipboard(result)
    }
}

// MARK: - 复制所在目录路径

/// 复制文件所在目录的路径
public final class CopyDirectoryPathAction: FinderAction {
    public let id = "copypath.directory"
    public let title = "复制所在目录路径"
    public let icon: NSImage? = NSImage(systemSymbolName: "folder", accessibilityDescription: "Copy Directory Path")
    public let category: ActionCategory = .copyPath

    public init() {}

    public func execute(with urls: [URL]) throws {
        guard let url = urls.first else { return }
        let directoryPath: String
        if url.hasDirectoryPath {
            directoryPath = url.path
        } else {
            directoryPath = url.deletingLastPathComponent().path
        }
        FileOperationService.shared.copyToClipboard(directoryPath)
    }
}
