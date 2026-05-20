import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    let menuBuilder = MenuBuilder()
    
    override init() {
        super.init()
        
        // 注册监控目录：用户主目录 + 所有已挂载卷
        var monitoredDirs: Set<URL> = []
        
        // 添加用户主目录
        monitoredDirs.insert(FileManager.default.homeDirectoryForCurrentUser)
        
        // 添加所有已挂载卷
        if let volumeURLs = FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: nil,
            options: [.skipHiddenVolumes]
        ) {
            monitoredDirs.formUnion(volumeURLs)
        }
        
        FIFinderSyncController.default().directoryURLs = monitoredDirs
        
        // 监听卷挂载/卸载通知
        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(
            self,
            selector: #selector(volumeDidMount(_:)),
            name: NSWorkspace.didMountNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(volumeDidUnmount(_:)),
            name: NSWorkspace.didUnmountNotification,
            object: nil
        )
    }
    
    // MARK: - Volume Monitoring
    
    @objc func volumeDidMount(_ notification: Notification) {
        updateMonitoredDirectories()
    }
    
    @objc func volumeDidUnmount(_ notification: Notification) {
        updateMonitoredDirectories()
    }
    
    func updateMonitoredDirectories() {
        var dirs: Set<URL> = [FileManager.default.homeDirectoryForCurrentUser]
        if let volumes = FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: nil,
            options: [.skipHiddenVolumes]
        ) {
            dirs.formUnion(volumes)
        }
        FIFinderSyncController.default().directoryURLs = dirs
    }
    
    // MARK: - Context Menu
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let items = FIFinderSyncController.default().selectedItemURLs() ?? []
        let targetURL = FIFinderSyncController.default().targetedURL()
        return menuBuilder.buildMenu(for: menuKind, selectedItems: items, targetDirectory: targetURL)
    }
    
    // MARK: - Toggle Hidden Files
    
    @objc func toggleHiddenFiles(_ sender: NSMenuItem) {
        // 读取当前隐藏文件显示状态
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        process.arguments = ["read", "com.apple.finder", "AppleShowAllFiles"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            NSLog("FinderRight: Failed to read hidden files preference: \(error)")
            return
        }
        
        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // 切换状态
        let newValue = (output.uppercased() == "YES" || output == "1") ? "NO" : "YES"
        
        // 写入新状态
        let writeProcess = Process()
        writeProcess.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        writeProcess.arguments = ["write", "com.apple.finder", "AppleShowAllFiles", newValue]
        
        do {
            try writeProcess.run()
            writeProcess.waitUntilExit()
        } catch {
            NSLog("FinderRight: Failed to write hidden files preference: \(error)")
            return
        }
        
        // 重启 Finder
        let killProcess = Process()
        killProcess.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
        killProcess.arguments = ["Finder"]
        
        do {
            try killProcess.run()
            killProcess.waitUntilExit()
        } catch {
            NSLog("FinderRight: Failed to restart Finder: \(error)")
        }
    }
    
    // MARK: - New File
    
    @objc func newFile(_ sender: NSMenuItem) {
        guard let directory = sender.representedObject as? URL else {
            NSLog("FinderRight: No directory for new file")
            return
        }
        
        guard let fileTag = NewFileTag(rawValue: sender.tag) else {
            NSLog("FinderRight: Unknown file tag: \(sender.tag)")
            return
        }
        
        let (ext, defaultContent) = fileTypeInfo(for: fileTag)
        let baseName = "untitled"
        let fileName = uniqueFileName(baseName: baseName, ext: ext, in: directory)
        let fileURL = directory.appendingPathComponent(fileName)
        
        do {
            try defaultContent.write(to: fileURL, atomically: true, encoding: .utf8)
            NSLog("FinderRight: Created file at \(fileURL.path)")
            
            // 在 Finder 中选中新创建的文件
            NSWorkspace.shared.activateFileViewerSelecting([fileURL])
        } catch {
            NSLog("FinderRight: Failed to create file: \(error)")
        }
    }
    
    /// 根据文件类型返回扩展名和默认内容
    private func fileTypeInfo(for tag: NewFileTag) -> (ext: String, content: String) {
        switch tag {
        case .txt:
            return ("txt", "")
        case .md:
            return ("md", "# Untitled\n\n")
        case .html:
            return ("html", """
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Untitled</title>
            </head>
            <body>
                
            </body>
            </html>
            """)
        case .py:
            return ("py", "#!/usr/bin/env python3\n# -*- coding: utf-8 -*-\n\n")
        case .sh:
            return ("sh", "#!/bin/bash\n\n")
        case .json:
            return ("json", "{\n    \n}\n")
        case .xml:
            return ("xml", "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<root>\n    \n</root>\n")
        case .csv:
            return ("csv", "")
        case .swift:
            return ("swift", "import Foundation\n\n")
        case .js:
            return ("js", "\"use strict\";\n\n")
        }
    }
    
    /// 生成唯一文件名，避免冲突
    private func uniqueFileName(baseName: String, ext: String, in directory: URL) -> String {
        let fileName = "\(baseName).\(ext)"
        let fileURL = directory.appendingPathComponent(fileName)
        
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            return fileName
        }
        
        // 文件已存在，添加数字后缀
        var counter = 1
        while true {
            let numberedName = "\(baseName) \(counter).\(ext)"
            let numberedURL = directory.appendingPathComponent(numberedName)
            if !FileManager.default.fileExists(atPath: numberedURL.path) {
                return numberedName
            }
            counter += 1
            if counter > 9999 {
                // 防止无限循环
                return "\(baseName) \(Int.random(in: 10000...99999)).\(ext)"
            }
        }
    }
    
    // MARK: - Copy Path
    
    @objc func copyPath(_ sender: NSMenuItem) {
        guard let urls = sender.representedObject as? [URL], !urls.isEmpty else {
            NSLog("FinderRight: No URLs for copy path")
            return
        }
        
        guard let pathTag = CopyPathTag(rawValue: sender.tag) else {
            NSLog("FinderRight: Unknown copy path tag: \(sender.tag)")
            return
        }
        
        let paths: [String] = urls.map { url in
            switch pathTag {
            case .posixPath:
                return url.path
            case .quotedPath:
                return "'\(url.path)'"
            case .escapedPath:
                return url.path.replacingOccurrences(of: " ", with: "\\ ")
            case .fileName:
                return url.lastPathComponent
            case .folderPath:
                return url.deletingLastPathComponent().path
            case .fileURL:
                return url.absoluteString
            }
        }
        
        let result = paths.joined(separator: "\n")
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(result, forType: .string)
        
        NSLog("FinderRight: Copied path(s) to clipboard")
    }
    
    // MARK: - Open Terminal
    
    @objc func openTerminal(_ sender: NSMenuItem) {
        guard let directory = sender.representedObject as? URL else {
            NSLog("FinderRight: No directory for terminal")
            return
        }
        
        guard let termTag = TerminalTag(rawValue: sender.tag) else {
            NSLog("FinderRight: Unknown terminal tag: \(sender.tag)")
            return
        }
        
        let dirPath = directory.path
        
        switch termTag {
        case .terminalApp:
            openTerminalApp(at: dirPath)
        case .iterm2:
            openITerm2(at: dirPath)
        case .warp:
            openWarp(at: dirPath)
        }
    }
    
    private func openTerminalApp(at path: String) {
        let script = """
        tell application "Terminal"
            activate
            do script "cd \(shellEscaped(path))"
        end tell
        """
        runAppleScript(script)
    }
    
    private func openITerm2(at path: String) {
        let script = """
        tell application "iTerm"
            activate
            try
                set newWindow to (create window with default profile)
                tell current session of newWindow
                    write text "cd \(shellEscaped(path))"
                end tell
            on error
                tell current window
                    create tab with default profile
                    tell current session
                        write text "cd \(shellEscaped(path))"
                    end tell
                end tell
            end try
        end tell
        """
        runAppleScript(script)
    }
    
    private func openWarp(at path: String) {
        // Warp 支持通过 open 命令打开
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = ["-a", "Warp", path]
        
        do {
            try process.run()
        } catch {
            NSLog("FinderRight: Failed to open Warp: \(error)")
        }
    }
    
    // MARK: - Open Editor
    
    @objc func openEditor(_ sender: NSMenuItem) {
        guard let urls = sender.representedObject as? [URL], !urls.isEmpty else {
            NSLog("FinderRight: No URLs for editor")
            return
        }
        
        guard let editorTag = EditorTag(rawValue: sender.tag) else {
            NSLog("FinderRight: Unknown editor tag: \(sender.tag)")
            return
        }
        
        switch editorTag {
        case .vscode:
            openWithCommand("/usr/local/bin/code", fallback: "/opt/homebrew/bin/code", args: urls.map { $0.path })
        case .sublimeText:
            openWithCommand("/usr/local/bin/subl", fallback: "/opt/homebrew/bin/subl", args: urls.map { $0.path })
        case .textEdit:
            for url in urls {
                NSWorkspace.shared.open(
                    [url],
                    withAppBundleIdentifier: "com.apple.TextEdit",
                    options: [],
                    additionalEventParamDescriptor: nil,
                    launchIdentifiers: nil
                )
            }
        case .xcode:
            for url in urls {
                NSWorkspace.shared.open(
                    [url],
                    withAppBundleIdentifier: "com.apple.dt.Xcode",
                    options: [],
                    additionalEventParamDescriptor: nil,
                    launchIdentifiers: nil
                )
            }
        case .cursor:
            openWithCommand("/usr/local/bin/cursor", fallback: "/opt/homebrew/bin/cursor", args: urls.map { $0.path })
        }
    }
    
    /// 尝试使用命令行工具打开文件，支持 fallback 路径
    private func openWithCommand(_ primaryPath: String, fallback: String? = nil, args: [String]) {
        let commandPath: String
        if FileManager.default.fileExists(atPath: primaryPath) {
            commandPath = primaryPath
        } else if let fallback = fallback, FileManager.default.fileExists(atPath: fallback) {
            commandPath = fallback
        } else {
            NSLog("FinderRight: Command not found at \(primaryPath)")
            return
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: commandPath)
        process.arguments = args
        
        do {
            try process.run()
        } catch {
            NSLog("FinderRight: Failed to run \(commandPath): \(error)")
        }
    }
    
    // MARK: - File Operations
    
    @objc func fileOperation(_ sender: NSMenuItem) {
        guard let urls = sender.representedObject as? [URL], !urls.isEmpty else {
            NSLog("FinderRight: No URLs for file operation")
            return
        }
        
        guard let opsTag = FileOpsTag(rawValue: sender.tag) else {
            NSLog("FinderRight: Unknown file operation tag: \(sender.tag)")
            return
        }
        
        switch opsTag {
        case .moveToTrash:
            moveToTrash(urls: urls)
        case .duplicate:
            duplicateFiles(urls: urls)
        case .makeSymlink:
            makeSymlinks(urls: urls)
        case .showInfo:
            showInfo(urls: urls)
        case .revealInFinder:
            NSWorkspace.shared.activateFileViewerSelecting(urls)
        }
    }
    
    private func moveToTrash(urls: [URL]) {
        for url in urls {
            do {
                try FileManager.default.trashItem(at: url, resultingItemURL: nil)
                NSLog("FinderRight: Moved to trash: \(url.path)")
            } catch {
                NSLog("FinderRight: Failed to trash \(url.path): \(error)")
            }
        }
    }
    
    private func duplicateFiles(urls: [URL]) {
        for url in urls {
            let directory = url.deletingLastPathComponent()
            let baseName = url.deletingPathExtension().lastPathComponent
            let ext = url.pathExtension
            
            let copyName: String
            if ext.isEmpty {
                copyName = uniqueFileName(baseName: "\(baseName) copy", ext: "", in: directory)
                // 对无扩展名文件特殊处理
                let destURL = directory.appendingPathComponent("\(baseName) copy")
                var counter = 0
                var finalURL = destURL
                while FileManager.default.fileExists(atPath: finalURL.path) {
                    counter += 1
                    finalURL = directory.appendingPathComponent("\(baseName) copy \(counter)")
                }
                do {
                    try FileManager.default.copyItem(at: url, to: finalURL)
                    NSLog("FinderRight: Duplicated to \(finalURL.path)")
                } catch {
                    NSLog("FinderRight: Failed to duplicate \(url.path): \(error)")
                }
                continue
            } else {
                copyName = uniqueFileName(baseName: "\(baseName) copy", ext: ext, in: directory)
            }
            
            let destURL = directory.appendingPathComponent(copyName)
            
            do {
                try FileManager.default.copyItem(at: url, to: destURL)
                NSLog("FinderRight: Duplicated to \(destURL.path)")
            } catch {
                NSLog("FinderRight: Failed to duplicate \(url.path): \(error)")
            }
        }
    }
    
    private func makeSymlinks(urls: [URL]) {
        for url in urls {
            let directory = url.deletingLastPathComponent()
            let baseName = url.deletingPathExtension().lastPathComponent
            let ext = url.pathExtension
            
            let linkName: String
            if ext.isEmpty {
                linkName = "\(baseName) symlink"
            } else {
                linkName = "\(baseName) symlink.\(ext)"
            }
            
            let linkURL = directory.appendingPathComponent(linkName)
            
            do {
                try FileManager.default.createSymbolicLink(at: linkURL, withDestinationURL: url)
                NSLog("FinderRight: Created symlink at \(linkURL.path)")
            } catch {
                NSLog("FinderRight: Failed to create symlink for \(url.path): \(error)")
            }
        }
    }
    
    private func showInfo(urls: [URL]) {
        // 使用 AppleScript 打开 Finder 的"显示简介"窗口
        for url in urls {
            let script = """
            tell application "Finder"
                activate
                open information window of (POSIX file "\(url.path)" as alias)
            end tell
            """
            runAppleScript(script)
        }
    }
    
    // MARK: - Archive Operations
    
    @objc func archiveOperation(_ sender: NSMenuItem) {
        guard let urls = sender.representedObject as? [URL], !urls.isEmpty else {
            NSLog("FinderRight: No URLs for archive operation")
            return
        }
        
        guard let archiveTag = ArchiveTag(rawValue: sender.tag) else {
            NSLog("FinderRight: Unknown archive tag: \(sender.tag)")
            return
        }
        
        switch archiveTag {
        case .compressZip:
            compressToZip(urls: urls)
        case .compressTarGz:
            compressToTarGz(urls: urls)
        case .decompress:
            decompressFiles(urls: urls)
        }
    }
    
    private func compressToZip(urls: [URL]) {
        guard let firstURL = urls.first else { return }
        let directory = firstURL.deletingLastPathComponent()
        
        // 确定压缩包名称
        let archiveName: String
        if urls.count == 1 {
            archiveName = firstURL.deletingPathExtension().lastPathComponent
        } else {
            archiveName = "Archive"
        }
        
        let archiveURL = uniqueArchiveURL(baseName: archiveName, ext: "zip", in: directory)
        
        // 使用 ditto 命令创建 ZIP
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
        process.currentDirectoryURL = directory
        
        var args = ["-c", "-k", "--sequesterRsrc", "--keepParent"]
        for url in urls {
            args.append(url.lastPathComponent)
        }
        args.append(archiveURL.path)
        
        // 如果多个文件，使用 zip 命令代替
        if urls.count > 1 {
            let zipProcess = Process()
            zipProcess.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
            zipProcess.currentDirectoryURL = directory
            
            var zipArgs = ["-r", archiveURL.path]
            for url in urls {
                zipArgs.append(url.lastPathComponent)
            }
            zipProcess.arguments = zipArgs
            
            do {
                try zipProcess.run()
                zipProcess.waitUntilExit()
                NSLog("FinderRight: Created ZIP at \(archiveURL.path)")
                NSWorkspace.shared.activateFileViewerSelecting([archiveURL])
            } catch {
                NSLog("FinderRight: Failed to create ZIP: \(error)")
            }
        } else {
            process.arguments = args
            
            do {
                try process.run()
                process.waitUntilExit()
                NSLog("FinderRight: Created ZIP at \(archiveURL.path)")
                NSWorkspace.shared.activateFileViewerSelecting([archiveURL])
            } catch {
                NSLog("FinderRight: Failed to create ZIP: \(error)")
            }
        }
    }
    
    private func compressToTarGz(urls: [URL]) {
        guard let firstURL = urls.first else { return }
        let directory = firstURL.deletingLastPathComponent()
        
        let archiveName: String
        if urls.count == 1 {
            archiveName = firstURL.deletingPathExtension().lastPathComponent
        } else {
            archiveName = "Archive"
        }
        
        let archiveURL = uniqueArchiveURL(baseName: archiveName, ext: "tar.gz", in: directory)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/tar")
        process.currentDirectoryURL = directory
        
        var args = ["-czf", archiveURL.path]
        for url in urls {
            args.append(url.lastPathComponent)
        }
        process.arguments = args
        
        do {
            try process.run()
            process.waitUntilExit()
            NSLog("FinderRight: Created tar.gz at \(archiveURL.path)")
            NSWorkspace.shared.activateFileViewerSelecting([archiveURL])
        } catch {
            NSLog("FinderRight: Failed to create tar.gz: \(error)")
        }
    }
    
    private func decompressFiles(urls: [URL]) {
        for url in urls {
            let directory = url.deletingLastPathComponent()
            let ext = url.pathExtension.lowercased()
            
            let process = Process()
            process.currentDirectoryURL = directory
            
            switch ext {
            case "zip":
                process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
                process.arguments = ["-o", url.path, "-d", directory.path]
            case "gz", "tgz":
                process.executableURL = URL(fileURLWithPath: "/usr/bin/tar")
                process.arguments = ["-xzf", url.path, "-C", directory.path]
            case "bz2":
                process.executableURL = URL(fileURLWithPath: "/usr/bin/tar")
                process.arguments = ["-xjf", url.path, "-C", directory.path]
            case "tar":
                process.executableURL = URL(fileURLWithPath: "/usr/bin/tar")
                process.arguments = ["-xf", url.path, "-C", directory.path]
            default:
                // 尝试使用 tar 解压
                process.executableURL = URL(fileURLWithPath: "/usr/bin/tar")
                process.arguments = ["-xf", url.path, "-C", directory.path]
            }
            
            do {
                try process.run()
                process.waitUntilExit()
                NSLog("FinderRight: Decompressed \(url.path)")
            } catch {
                NSLog("FinderRight: Failed to decompress \(url.path): \(error)")
            }
        }
    }
    
    /// 生成唯一的压缩文件名
    private func uniqueArchiveURL(baseName: String, ext: String, in directory: URL) -> URL {
        let fileName = "\(baseName).\(ext)"
        let fileURL = directory.appendingPathComponent(fileName)
        
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL
        }
        
        var counter = 1
        while true {
            let numberedName = "\(baseName) \(counter).\(ext)"
            let numberedURL = directory.appendingPathComponent(numberedName)
            if !FileManager.default.fileExists(atPath: numberedURL.path) {
                return numberedURL
            }
            counter += 1
            if counter > 9999 {
                return directory.appendingPathComponent("\(baseName) \(Int.random(in: 10000...99999)).\(ext)")
            }
        }
    }
    
    // MARK: - Utility Methods
    
    /// 对路径进行 shell 转义
    private func shellEscaped(_ path: String) -> String {
        return "'" + path.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
    
    /// 执行 AppleScript
    private func runAppleScript(_ source: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let script = NSAppleScript(source: source) else {
                NSLog("FinderRight: Failed to create AppleScript")
                return
            }
            
            var errorDict: NSDictionary?
            script.executeAndReturnError(&errorDict)
            
            if let error = errorDict {
                NSLog("FinderRight: AppleScript error: \(error)")
            }
        }
    }
}
