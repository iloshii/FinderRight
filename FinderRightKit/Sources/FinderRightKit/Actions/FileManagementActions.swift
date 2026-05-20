import AppKit

// MARK: - 剪切/粘贴用的自定义 Pasteboard Type

/// 自定义 pasteboard type，用于标记剪切操作
private let cutPasteboardType = NSPasteboard.PasteboardType("com.finderright.cut-files")

// MARK: - 剪切文件

/// 将选中文件标记为"剪切"并存入剪贴板
public final class CutFilesAction: FinderAction {
    public let id = "fileops.cut"
    public let title = "剪切文件"
    public let icon: NSImage? = NSImage(systemSymbolName: "scissors", accessibilityDescription: "Cut")
    public let category: ActionCategory = .fileOps

    public init() {}

    public func execute(with urls: [URL]) throws {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        // 将文件 URL 写入剪贴板
        pasteboard.writeObjects(urls as [NSURL])

        // 添加自定义 type 标记为剪切操作
        let urlStrings = urls.map { $0.absoluteString }.joined(separator: "\n")
        pasteboard.setString(urlStrings, forType: cutPasteboardType)
    }
}

// MARK: - 粘贴文件

/// 从剪贴板粘贴文件（如标记为剪切则移动，否则复制）
public final class PasteFilesAction: FinderAction {
    public let id = "fileops.paste"
    public let title = "粘贴文件"
    public let icon: NSImage? = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Paste")
    public let category: ActionCategory = .fileOps

    public init() {}

    public func execute(with urls: [URL]) throws {
        guard let destinationDir = urls.first else { return }
        let destination = destinationDir.hasDirectoryPath ? destinationDir : destinationDir.deletingLastPathComponent()

        let pasteboard = NSPasteboard.general
        let isCut = pasteboard.string(forType: cutPasteboardType) != nil

        guard let items = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] else {
            return
        }

        let fileManager = FileManager.default

        for sourceURL in items {
            let destURL = destination.appendingPathComponent(sourceURL.lastPathComponent)

            if isCut {
                try fileManager.moveItem(at: sourceURL, to: destURL)
            } else {
                try fileManager.copyItem(at: sourceURL, to: destURL)
            }
        }

        // 清除剪贴板中的剪切标记
        if isCut {
            pasteboard.clearContents()
        }
    }
}

// MARK: - 移动到文件夹

/// 弹出选择目录面板并移动文件
public final class MoveToFolderAction: FinderAction {
    public let id = "fileops.move"
    public let title = "移动到..."
    public let icon: NSImage? = NSImage(systemSymbolName: "folder.badge.plus", accessibilityDescription: "Move To Folder")
    public let category: ActionCategory = .fileOps

    public init() {}

    public func execute(with urls: [URL]) throws {
        guard !urls.isEmpty else { return }

        let panel = NSOpenPanel()
        panel.title = "选择目标文件夹"
        panel.message = "选择要移动到的目标文件夹"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true

        let response = panel.runModal()
        guard response == .OK, let destination = panel.url else { return }

        let fileManager = FileManager.default
        for url in urls {
            let destURL = destination.appendingPathComponent(url.lastPathComponent)
            try fileManager.moveItem(at: url, to: destURL)
        }
    }
}

// MARK: - 复制到文件夹

/// 弹出选择目录面板并复制文件
public final class CopyToFolderAction: FinderAction {
    public let id = "fileops.copy"
    public let title = "复制到..."
    public let icon: NSImage? = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "Copy To Folder")
    public let category: ActionCategory = .fileOps

    public init() {}

    public func execute(with urls: [URL]) throws {
        guard !urls.isEmpty else { return }

        let panel = NSOpenPanel()
        panel.title = "选择目标文件夹"
        panel.message = "选择要复制到的目标文件夹"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true

        let response = panel.runModal()
        guard response == .OK, let destination = panel.url else { return }

        let fileManager = FileManager.default
        for url in urls {
            let destURL = destination.appendingPathComponent(url.lastPathComponent)
            try fileManager.copyItem(at: url, to: destURL)
        }
    }
}

// MARK: - 永久删除

/// 永久删除文件（不经回收站）
public final class DeletePermanentlyAction: FinderAction {
    public let id = "fileops.delete"
    public let title = "永久删除"
    public let icon: NSImage? = NSImage(systemSymbolName: "trash.slash", accessibilityDescription: "Delete Permanently")
    public let category: ActionCategory = .fileOps

    public init() {}

    public func execute(with urls: [URL]) throws {
        let fileManager = FileManager.default
        for url in urls {
            try fileManager.removeItem(at: url)
        }
    }
}
