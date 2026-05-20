import AppKit

// MARK: - 新建文本文件

/// 新建 .txt 文件
public final class NewTextFileAction: FinderAction {
    public let id = "newfile.txt"
    public let title = "新建文本文件"
    public let icon: NSImage? = NSImage(systemSymbolName: "doc.text", accessibilityDescription: "Text File")
    public let category: ActionCategory = .newFile

    public init() {}

    public func execute(with urls: [URL]) throws {
        guard let directory = urls.first else { return }
        let dir = directory.hasDirectoryPath ? directory : directory.deletingLastPathComponent()
        try FileOperationService.shared.createFile(
            at: dir,
            name: "untitled",
            extension: "txt",
            content: ""
        )
    }
}

// MARK: - 新建 Markdown 文件

/// 新建 .md 文件
public final class NewMarkdownFileAction: FinderAction {
    public let id = "newfile.md"
    public let title = "新建 Markdown 文件"
    public let icon: NSImage? = NSImage(systemSymbolName: "doc.richtext", accessibilityDescription: "Markdown File")
    public let category: ActionCategory = .newFile

    public init() {}

    public func execute(with urls: [URL]) throws {
        guard let directory = urls.first else { return }
        let dir = directory.hasDirectoryPath ? directory : directory.deletingLastPathComponent()
        let content = """
        # Title

        ## Overview

        Write your content here.
        """
        try FileOperationService.shared.createFile(
            at: dir,
            name: "untitled",
            extension: "md",
            content: content
        )
    }
}

// MARK: - 新建 HTML 文件

/// 新建 .html 文件
public final class NewHTMLFileAction: FinderAction {
    public let id = "newfile.html"
    public let title = "新建 HTML 文件"
    public let icon: NSImage? = NSImage(systemSymbolName: "globe", accessibilityDescription: "HTML File")
    public let category: ActionCategory = .newFile

    public init() {}

    public func execute(with urls: [URL]) throws {
        guard let directory = urls.first else { return }
        let dir = directory.hasDirectoryPath ? directory : directory.deletingLastPathComponent()
        let content = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Document</title>
        </head>
        <body>

        </body>
        </html>
        """
        try FileOperationService.shared.createFile(
            at: dir,
            name: "index",
            extension: "html",
            content: content
        )
    }
}

// MARK: - 新建 Python 文件

/// 新建 .py 文件
public final class NewPythonFileAction: FinderAction {
    public let id = "newfile.py"
    public let title = "新建 Python 文件"
    public let icon: NSImage? = NSImage(systemSymbolName: "chevron.left.forwardslash.chevron.right", accessibilityDescription: "Python File")
    public let category: ActionCategory = .newFile

    public init() {}

    public func execute(with urls: [URL]) throws {
        guard let directory = urls.first else { return }
        let dir = directory.hasDirectoryPath ? directory : directory.deletingLastPathComponent()
        let content = """
        #!/usr/bin/env python3
        # -*- coding: utf-8 -*-

        \"\"\"Module docstring.\"\"\"


        def main():
            pass


        if __name__ == "__main__":
            main()
        """
        try FileOperationService.shared.createFile(
            at: dir,
            name: "script",
            extension: "py",
            content: content
        )
    }
}

// MARK: - 新建 Swift 文件

/// 新建 .swift 文件
public final class NewSwiftFileAction: FinderAction {
    public let id = "newfile.swift"
    public let title = "新建 Swift 文件"
    public let icon: NSImage? = NSImage(systemSymbolName: "swift", accessibilityDescription: "Swift File")
    public let category: ActionCategory = .newFile

    public init() {}

    public func execute(with urls: [URL]) throws {
        guard let directory = urls.first else { return }
        let dir = directory.hasDirectoryPath ? directory : directory.deletingLastPathComponent()
        let content = """
        import Foundation

        """
        try FileOperationService.shared.createFile(
            at: dir,
            name: "Untitled",
            extension: "swift",
            content: content
        )
    }
}

// MARK: - 新建 JSON 文件

/// 新建 .json 文件
public final class NewJSONFileAction: FinderAction {
    public let id = "newfile.json"
    public let title = "新建 JSON 文件"
    public let icon: NSImage? = NSImage(systemSymbolName: "curlybraces", accessibilityDescription: "JSON File")
    public let category: ActionCategory = .newFile

    public init() {}

    public func execute(with urls: [URL]) throws {
        guard let directory = urls.first else { return }
        let dir = directory.hasDirectoryPath ? directory : directory.deletingLastPathComponent()
        let content = """
        {

        }
        """
        try FileOperationService.shared.createFile(
            at: dir,
            name: "data",
            extension: "json",
            content: content
        )
    }
}

// MARK: - 新建 Shell 脚本文件

/// 新建 .sh 文件
public final class NewShellScriptAction: FinderAction {
    public let id = "newfile.sh"
    public let title = "新建 Shell 脚本"
    public let icon: NSImage? = NSImage(systemSymbolName: "terminal", accessibilityDescription: "Shell Script")
    public let category: ActionCategory = .newFile

    public init() {}

    public func execute(with urls: [URL]) throws {
        guard let directory = urls.first else { return }
        let dir = directory.hasDirectoryPath ? directory : directory.deletingLastPathComponent()
        let content = """
        #!/bin/bash
        set -euo pipefail

        # Script description here

        """
        try FileOperationService.shared.createFile(
            at: dir,
            name: "script",
            extension: "sh",
            content: content
        )
    }
}
