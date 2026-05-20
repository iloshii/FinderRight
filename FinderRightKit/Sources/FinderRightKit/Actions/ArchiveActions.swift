import AppKit

// MARK: - 压缩为 ZIP

/// 将选中文件/目录压缩为 ZIP
public final class CompressToZipAction: FinderAction {
    public let id = "archive.compress"
    public let title = "压缩为 ZIP"
    public let icon: NSImage? = NSImage(systemSymbolName: "archivebox", accessibilityDescription: "Compress")
    public let category: ActionCategory = .archive

    public init() {}

    public func execute(with urls: [URL]) throws {
        try FileOperationService.shared.compressFiles(urls)
    }
}

// MARK: - 解压到当前目录

/// 将压缩文件解压到当前目录
public final class DecompressHereAction: FinderAction {
    public let id = "archive.decompress_here"
    public let title = "解压到当前目录"
    public let icon: NSImage? = NSImage(systemSymbolName: "archivebox.fill", accessibilityDescription: "Decompress Here")
    public let category: ActionCategory = .archive

    public init() {}

    public func execute(with urls: [URL]) throws {
        for url in urls {
            let ext = url.pathExtension.lowercased()
            guard ["zip", "tar", "gz", "tgz", "bz2", "xz"].contains(ext) else { continue }
            try FileOperationService.shared.decompressFile(url, toFolder: false)
        }
    }
}

// MARK: - 解压到同名文件夹

/// 将压缩文件解压到同名文件夹
public final class DecompressToFolderAction: FinderAction {
    public let id = "archive.decompress_folder"
    public let title = "解压到同名文件夹"
    public let icon: NSImage? = NSImage(systemSymbolName: "folder.badge.gearshape", accessibilityDescription: "Decompress To Folder")
    public let category: ActionCategory = .archive

    public init() {}

    public func execute(with urls: [URL]) throws {
        for url in urls {
            let ext = url.pathExtension.lowercased()
            guard ["zip", "tar", "gz", "tgz", "bz2", "xz"].contains(ext) else { continue }
            try FileOperationService.shared.decompressFile(url, toFolder: true)
        }
    }
}
