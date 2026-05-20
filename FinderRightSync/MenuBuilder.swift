import Cocoa
import FinderSync

// MARK: - Tag Constants

/// 新建文件操作的 tag 常量
enum NewFileTag: Int {
    case txt = 0
    case md = 1
    case html = 2
    case py = 3
    case sh = 4
    case json = 5
    case xml = 6
    case csv = 7
    case swift = 8
    case js = 9
}

/// 复制路径操作的 tag 常量
enum CopyPathTag: Int {
    case posixPath = 0       // /Users/xxx/file.txt
    case quotedPath = 1      // '/Users/xxx/file.txt'
    case escapedPath = 2     // /Users/xxx/file\ name.txt
    case fileName = 3        // file.txt
    case folderPath = 4      // /Users/xxx/
    case fileURL = 5         // file:///Users/xxx/file.txt
}

/// 终端操作的 tag 常量
enum TerminalTag: Int {
    case terminalApp = 0
    case iterm2 = 1
    case warp = 2
}

/// 编辑器操作的 tag 常量
enum EditorTag: Int {
    case vscode = 0
    case sublimeText = 1
    case textEdit = 2
    case xcode = 3
    case cursor = 4
}

/// 文件操作的 tag 常量
enum FileOpsTag: Int {
    case moveToTrash = 0
    case duplicate = 1
    case makeSymlink = 2
    case showInfo = 3
    case revealInFinder = 4
}

/// 压缩解压操作的 tag 常量
enum ArchiveTag: Int {
    case compressZip = 0
    case compressTarGz = 1
    case decompress = 2
}

// MARK: - MenuBuilder

class MenuBuilder {
    
    /// 构建主右键菜单
    func buildMenu(for menuKind: FIMenuKind, selectedItems: [URL], targetDirectory: URL?) -> NSMenu {
        let menu = NSMenu(title: "FinderRight")
        
        // 获取上下文信息
        let hasSelection = !selectedItems.isEmpty
        let directory = targetDirectory ?? selectedItems.first?.deletingLastPathComponent()
        
        // 1. 新建文件子菜单（仅在文件夹背景右键时显示）
        if menuKind == .contextualMenuForContainer || menuKind == .contextualMenuForSidebar || !hasSelection {
            let newFileMenu = buildNewFileMenu(in: directory)
            let newFileItem = NSMenuItem(title: "📄 新建文件", action: nil, keyEquivalent: "")
            newFileItem.submenu = newFileMenu
            menu.addItem(newFileItem)
        }
        
        // 2. 复制路径子菜单
        if hasSelection {
            let copyPathMenu = buildCopyPathMenu(for: selectedItems)
            let copyPathItem = NSMenuItem(title: "📋 复制路径", action: nil, keyEquivalent: "")
            copyPathItem.submenu = copyPathMenu
            menu.addItem(copyPathItem)
        }
        
        // 分隔线
        menu.addItem(NSMenuItem.separator())
        
        // 3. 打开终端子菜单
        let terminalMenu = buildTerminalMenu(for: directory, selectedItems: selectedItems)
        let terminalItem = NSMenuItem(title: "💻 打开终端", action: nil, keyEquivalent: "")
        terminalItem.submenu = terminalMenu
        menu.addItem(terminalItem)
        
        // 4. 打开编辑器子菜单
        if hasSelection {
            let editorMenu = buildEditorMenu(for: selectedItems)
            let editorItem = NSMenuItem(title: "✏️ 打开编辑器", action: nil, keyEquivalent: "")
            editorItem.submenu = editorMenu
            menu.addItem(editorItem)
        }
        
        // 分隔线
        menu.addItem(NSMenuItem.separator())
        
        // 5. 文件操作
        if hasSelection {
            let fileOpsMenu = buildFileOpsMenu(for: selectedItems)
            let fileOpsItem = NSMenuItem(title: "📁 文件操作", action: nil, keyEquivalent: "")
            fileOpsItem.submenu = fileOpsMenu
            menu.addItem(fileOpsItem)
        }
        
        // 6. 压缩/解压
        if hasSelection {
            let archiveMenu = buildArchiveMenu(for: selectedItems)
            let archiveItem = NSMenuItem(title: "🗜️ 压缩解压", action: nil, keyEquivalent: "")
            archiveItem.submenu = archiveMenu
            menu.addItem(archiveItem)
        }
        
        // 分隔线
        menu.addItem(NSMenuItem.separator())
        
        // 7. 显示/隐藏 隐藏文件
        let hiddenItem = NSMenuItem(
            title: "👁 切换隐藏文件",
            action: #selector(FinderSync.toggleHiddenFiles(_:)),
            keyEquivalent: ""
        )
        menu.addItem(hiddenItem)
        
        return menu
    }
    
    // MARK: - 新建文件子菜单
    
    func buildNewFileMenu(in directory: URL?) -> NSMenu {
        let menu = NSMenu(title: "新建文件")
        
        let fileTypes: [(String, String, NewFileTag)] = [
            ("📝 文本文件 (.txt)", "txt", .txt),
            ("📖 Markdown (.md)", "md", .md),
            ("🌐 HTML 文件 (.html)", "html", .html),
            ("🐍 Python 脚本 (.py)", "py", .py),
            ("🔧 Shell 脚本 (.sh)", "sh", .sh),
            ("📊 JSON 文件 (.json)", "json", .json),
            ("📃 XML 文件 (.xml)", "xml", .xml),
            ("📈 CSV 文件 (.csv)", "csv", .csv),
            ("🍎 Swift 文件 (.swift)", "swift", .swift),
            ("🟨 JavaScript (.js)", "js", .js),
        ]
        
        for (title, _, tag) in fileTypes {
            let item = NSMenuItem(
                title: title,
                action: #selector(FinderSync.newFile(_:)),
                keyEquivalent: ""
            )
            item.tag = tag.rawValue
            item.representedObject = directory
            menu.addItem(item)
        }
        
        return menu
    }
    
    // MARK: - 复制路径子菜单
    
    func buildCopyPathMenu(for urls: [URL]) -> NSMenu {
        let menu = NSMenu(title: "复制路径")
        
        let pathTypes: [(String, CopyPathTag)] = [
            ("📎 POSIX 路径", .posixPath),
            ("📎 带引号路径", .quotedPath),
            ("📎 转义路径", .escapedPath),
            ("📎 文件名", .fileName),
            ("📎 所在目录", .folderPath),
            ("📎 file:// URL", .fileURL),
        ]
        
        for (title, tag) in pathTypes {
            let item = NSMenuItem(
                title: title,
                action: #selector(FinderSync.copyPath(_:)),
                keyEquivalent: ""
            )
            item.tag = tag.rawValue
            item.representedObject = urls
            menu.addItem(item)
        }
        
        return menu
    }
    
    // MARK: - 打开终端子菜单
    
    func buildTerminalMenu(for directory: URL?, selectedItems: [URL]) -> NSMenu {
        let menu = NSMenu(title: "打开终端")
        
        // 确定终端打开路径：如果选中的是文件夹则用该文件夹，否则用当前目录
        let resolvedDir: URL? = {
            if let firstItem = selectedItems.first {
                var isDir: ObjCBool = false
                if FileManager.default.fileExists(atPath: firstItem.path, isDirectory: &isDir), isDir.boolValue {
                    return firstItem
                }
            }
            return directory
        }()
        
        let terminals: [(String, TerminalTag)] = [
            ("🖥 终端.app", .terminalApp),
            ("🦄 iTerm2", .iterm2),
            ("🚀 Warp", .warp),
        ]
        
        for (title, tag) in terminals {
            let item = NSMenuItem(
                title: title,
                action: #selector(FinderSync.openTerminal(_:)),
                keyEquivalent: ""
            )
            item.tag = tag.rawValue
            item.representedObject = resolvedDir
            menu.addItem(item)
        }
        
        return menu
    }
    
    // MARK: - 打开编辑器子菜单
    
    func buildEditorMenu(for urls: [URL]) -> NSMenu {
        let menu = NSMenu(title: "打开编辑器")
        
        let editors: [(String, EditorTag)] = [
            ("💎 VS Code", .vscode),
            ("🔶 Sublime Text", .sublimeText),
            ("📝 文本编辑", .textEdit),
            ("🔨 Xcode", .xcode),
            ("✨ Cursor", .cursor),
        ]
        
        for (title, tag) in editors {
            let item = NSMenuItem(
                title: title,
                action: #selector(FinderSync.openEditor(_:)),
                keyEquivalent: ""
            )
            item.tag = tag.rawValue
            item.representedObject = urls
            menu.addItem(item)
        }
        
        return menu
    }
    
    // MARK: - 文件操作子菜单
    
    func buildFileOpsMenu(for urls: [URL]) -> NSMenu {
        let menu = NSMenu(title: "文件操作")
        
        let ops: [(String, FileOpsTag)] = [
            ("🗑 移到废纸篓", .moveToTrash),
            ("📑 创建副本", .duplicate),
            ("🔗 创建符号链接", .makeSymlink),
            ("ℹ️ 显示简介", .showInfo),
            ("📂 在 Finder 中显示", .revealInFinder),
        ]
        
        for (title, tag) in ops {
            let item = NSMenuItem(
                title: title,
                action: #selector(FinderSync.fileOperation(_:)),
                keyEquivalent: ""
            )
            item.tag = tag.rawValue
            item.representedObject = urls
            menu.addItem(item)
        }
        
        return menu
    }
    
    // MARK: - 压缩解压子菜单
    
    func buildArchiveMenu(for urls: [URL]) -> NSMenu {
        let menu = NSMenu(title: "压缩解压")
        
        // 检查是否有压缩文件
        let archiveExtensions = Set(["zip", "tar", "gz", "tgz", "tar.gz", "bz2", "7z", "rar"])
        let hasArchives = urls.contains { archiveExtensions.contains($0.pathExtension.lowercased()) }
        
        var items: [(String, ArchiveTag)] = [
            ("📦 压缩为 ZIP", .compressZip),
            ("📦 压缩为 tar.gz", .compressTarGz),
        ]
        
        if hasArchives {
            items.append(("📂 解压到当前目录", .decompress))
        }
        
        for (title, tag) in items {
            let item = NSMenuItem(
                title: title,
                action: #selector(FinderSync.archiveOperation(_:)),
                keyEquivalent: ""
            )
            item.tag = tag.rawValue
            item.representedObject = urls
            menu.addItem(item)
        }
        
        return menu
    }
}
