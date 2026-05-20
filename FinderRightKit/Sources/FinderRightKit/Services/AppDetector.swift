import AppKit

// MARK: - 已安装应用信息

/// 已安装应用的信息
public struct InstalledApp: Equatable, Hashable {
    public let name: String
    public let bundleId: String
    public let url: URL

    public init(name: String, bundleId: String, url: URL) {
        self.name = name
        self.bundleId = bundleId
        self.url = url
    }
}

// MARK: - 应用检测器

/// 检测系统已安装的终端和编辑器应用
public final class AppDetector {

    public static let shared = AppDetector()

    private init() {}

    // MARK: - 终端应用定义

    /// 支持的终端应用列表 (name, bundleId)
    public static let terminalApps: [(name: String, bundleId: String)] = [
        ("Terminal", "com.apple.Terminal"),
        ("iTerm2", "com.googlecode.iterm2"),
        ("Warp", "dev.warp.Warp-Stable"),
        ("Alacritty", "org.alacritty"),
        ("Kitty", "net.kovidgoyal.kitty"),
    ]

    // MARK: - 编辑器应用定义

    /// 支持的编辑器应用列表 (name, bundleId)
    public static let editorApps: [(name: String, bundleId: String)] = [
        ("VS Code", "com.microsoft.VSCode"),
        ("Cursor", "com.todesktop.230313mzl4w4u92"),
        ("Sublime Text", "com.sublimetext.4"),
        ("Zed", "dev.zed.Zed"),
        ("Nova", "com.panic.Nova"),
    ]

    // MARK: - 检测方法

    /// 检测指定 bundle identifier 的应用是否已安装
    public func isAppInstalled(bundleId: String) -> Bool {
        return NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) != nil
    }

    /// 获取指定 bundle identifier 的应用信息
    public func appInfo(name: String, bundleId: String) -> InstalledApp? {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) else {
            return nil
        }
        return InstalledApp(name: name, bundleId: bundleId, url: url)
    }

    /// 获取所有已安装的终端应用
    public func installedTerminals() -> [InstalledApp] {
        return Self.terminalApps.compactMap { appInfo(name: $0.name, bundleId: $0.bundleId) }
    }

    /// 获取所有已安装的编辑器应用
    public func installedEditors() -> [InstalledApp] {
        return Self.editorApps.compactMap { appInfo(name: $0.name, bundleId: $0.bundleId) }
    }

    /// 获取所有已安装的应用（终端 + 编辑器）
    public func allInstalledApps() -> [InstalledApp] {
        return installedTerminals() + installedEditors()
    }
}
