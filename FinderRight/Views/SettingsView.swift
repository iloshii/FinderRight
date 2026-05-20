import SwiftUI

// MARK: - 功能分类定义

enum ActionCategory: String, CaseIterable, Identifiable {
    case fileOperation = "文件操作"
    case development = "开发工具"
    case quickAction = "快捷操作"
    case clipboard = "剪贴板"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .fileOperation: return "folder"
        case .development: return "terminal"
        case .quickAction: return "bolt"
        case .clipboard: return "doc.on.clipboard"
        }
    }

    var features: [FeatureItem] {
        switch self {
        case .fileOperation:
            return [
                FeatureItem(key: "feature.newFile", name: "新建文件", description: "在当前目录新建文件", icon: "doc.badge.plus"),
                FeatureItem(key: "feature.newFolder", name: "新建文件夹", description: "在当前目录新建文件夹", icon: "folder.badge.plus"),
                FeatureItem(key: "feature.copyPath", name: "复制路径", description: "复制文件或文件夹的完整路径", icon: "doc.on.doc"),
                FeatureItem(key: "feature.moveToTrash", name: "移到废纸篓", description: "将选中项移到废纸篓", icon: "trash"),
            ]
        case .development:
            return [
                FeatureItem(key: "feature.openInTerminal", name: "在终端中打开", description: "使用默认终端打开当前目录", icon: "terminal"),
                FeatureItem(key: "feature.openInEditor", name: "在编辑器中打开", description: "使用默认编辑器打开文件", icon: "curlybraces"),
                FeatureItem(key: "feature.gitInit", name: "Git 初始化", description: "在当前目录初始化 Git 仓库", icon: "arrow.triangle.branch"),
            ]
        case .quickAction:
            return [
                FeatureItem(key: "feature.compress", name: "压缩", description: "压缩选中的文件或文件夹", icon: "archivebox"),
                FeatureItem(key: "feature.share", name: "分享", description: "快速分享选中的文件", icon: "square.and.arrow.up"),
                FeatureItem(key: "feature.preview", name: "快速预览", description: "预览文件内容", icon: "eye"),
            ]
        case .clipboard:
            return [
                FeatureItem(key: "feature.copyFileName", name: "复制文件名", description: "复制文件名到剪贴板", icon: "textformat"),
                FeatureItem(key: "feature.copyRelativePath", name: "复制相对路径", description: "复制相对路径到剪贴板", icon: "link"),
            ]
        }
    }
}

struct FeatureItem: Identifiable {
    let key: String
    let name: String
    let description: String
    let icon: String

    var id: String { key }
}

// MARK: - 终端 & 编辑器定义

struct TerminalApp: Identifiable, Hashable {
    let id: String
    let name: String
    let bundleIdentifier: String
    let icon: String

    static let knownTerminals: [TerminalApp] = [
        TerminalApp(id: "terminal", name: "终端", bundleIdentifier: "com.apple.Terminal", icon: "terminal"),
        TerminalApp(id: "iterm", name: "iTerm2", bundleIdentifier: "com.googlecode.iterm2", icon: "terminal.fill"),
        TerminalApp(id: "warp", name: "Warp", bundleIdentifier: "dev.warp.Warp-Stable", icon: "terminal.fill"),
        TerminalApp(id: "alacritty", name: "Alacritty", bundleIdentifier: "org.alacritty", icon: "terminal.fill"),
        TerminalApp(id: "kitty", name: "Kitty", bundleIdentifier: "net.kovidgoyal.kitty", icon: "terminal.fill"),
    ]
}

struct EditorApp: Identifiable, Hashable {
    let id: String
    let name: String
    let bundleIdentifier: String
    let icon: String

    static let knownEditors: [EditorApp] = [
        EditorApp(id: "textedit", name: "文本编辑", bundleIdentifier: "com.apple.TextEdit", icon: "doc.text"),
        EditorApp(id: "vscode", name: "Visual Studio Code", bundleIdentifier: "com.microsoft.VSCode", icon: "curlybraces"),
        EditorApp(id: "cursor", name: "Cursor", bundleIdentifier: "com.todesktop.230313mzl4w4u92", icon: "curlybraces"),
        EditorApp(id: "sublime", name: "Sublime Text", bundleIdentifier: "com.sublimetext.4", icon: "curlybraces.square"),
        EditorApp(id: "xcode", name: "Xcode", bundleIdentifier: "com.apple.dt.Xcode", icon: "hammer"),
        EditorApp(id: "nova", name: "Nova", bundleIdentifier: "com.panic.Nova", icon: "star"),
        EditorApp(id: "bbedit", name: "BBEdit", bundleIdentifier: "com.barebones.bbedit", icon: "doc.plaintext"),
    ]
}

// MARK: - SharedDefaults

final class SharedDefaults: ObservableObject {
    static let suiteName = "group.com.finderright.shared"
    private let defaults: UserDefaults

    init() {
        defaults = UserDefaults(suiteName: SharedDefaults.suiteName) ?? .standard
    }

    func bool(forKey key: String, defaultValue: Bool = true) -> Bool {
        if defaults.object(forKey: key) == nil {
            return defaultValue
        }
        return defaults.bool(forKey: key)
    }

    func set(_ value: Bool, forKey key: String) {
        defaults.set(value, forKey: key)
        objectWillChange.send()
    }

    func string(forKey key: String, defaultValue: String = "") -> String {
        defaults.string(forKey: key) ?? defaultValue
    }

    func set(_ value: String, forKey key: String) {
        defaults.set(value, forKey: key)
        objectWillChange.send()
    }
}

// MARK: - SettingsView

struct SettingsView: View {
    private enum SettingsTab: String, CaseIterable {
        case general = "通用"
        case features = "功能"
        case tools = "终端 / 编辑器"
        case about = "关于"

        var icon: String {
            switch self {
            case .general: return "gearshape"
            case .features: return "slider.horizontal.3"
            case .tools: return "terminal"
            case .about: return "info.circle"
            }
        }
    }

    var body: some View {
        TabView {
            GeneralTab()
                .tabItem {
                    Label(SettingsTab.general.rawValue, systemImage: SettingsTab.general.icon)
                }
                .tag(SettingsTab.general)

            FeaturesTab()
                .tabItem {
                    Label(SettingsTab.features.rawValue, systemImage: SettingsTab.features.icon)
                }
                .tag(SettingsTab.features)

            ToolsTab()
                .tabItem {
                    Label(SettingsTab.tools.rawValue, systemImage: SettingsTab.tools.icon)
                }
                .tag(SettingsTab.tools)

            AboutTab()
                .tabItem {
                    Label(SettingsTab.about.rawValue, systemImage: SettingsTab.about.icon)
                }
                .tag(SettingsTab.about)
        }
        .frame(width: 520, height: 440)
    }
}

// MARK: - 通用 Tab

struct GeneralTab: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("showMenuBarIcon") private var showMenuBarIcon = true

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $launchAtLogin) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("开机自动启动")
                        Text("登录时自动运行 FinderRight")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Toggle(isOn: $showMenuBarIcon) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("显示菜单栏图标")
                        Text("在菜单栏显示 FinderRight 图标")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("启动")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - 功能 Tab

struct FeaturesTab: View {
    @StateObject private var sharedDefaults = SharedDefaults()

    var body: some View {
        Form {
            ForEach(ActionCategory.allCases) { category in
                Section {
                    DisclosureGroup {
                        ForEach(category.features) { feature in
                            FeatureToggleRow(
                                feature: feature,
                                sharedDefaults: sharedDefaults
                            )
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: category.icon)
                                .foregroundColor(.accentColor)
                                .frame(width: 20)
                            Text(category.rawValue)
                                .font(.headline)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - 终端/编辑器 Tab

struct ToolsTab: View {
    @StateObject private var sharedDefaults = SharedDefaults()
    @State private var availableTerminals: [TerminalApp] = []
    @State private var availableEditors: [EditorApp] = []
    @State private var selectedTerminalID: String = "terminal"
    @State private var selectedEditorID: String = "textedit"

    var body: some View {
        Form {
            Section {
                Picker("默认终端", selection: $selectedTerminalID) {
                    ForEach(availableTerminals) { terminal in
                        Label(terminal.name, systemImage: terminal.icon)
                            .tag(terminal.id)
                    }
                }
                .onChange(of: selectedTerminalID) { _, newValue in
                    sharedDefaults.set(newValue, forKey: "defaultTerminal")
                }
            } header: {
                Text("终端")
            } footer: {
                Text("选择右键菜单中「在终端中打开」使用的终端应用")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section {
                Picker("默认编辑器", selection: $selectedEditorID) {
                    ForEach(availableEditors) { editor in
                        Label(editor.name, systemImage: editor.icon)
                            .tag(editor.id)
                    }
                }
                .onChange(of: selectedEditorID) { _, newValue in
                    sharedDefaults.set(newValue, forKey: "defaultEditor")
                }
            } header: {
                Text("编辑器")
            } footer: {
                Text("选择右键菜单中「在编辑器中打开」使用的编辑器应用")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
        .onAppear {
            detectInstalledApps()
            selectedTerminalID = sharedDefaults.string(forKey: "defaultTerminal", defaultValue: "terminal")
            selectedEditorID = sharedDefaults.string(forKey: "defaultEditor", defaultValue: "textedit")
        }
    }

    private func detectInstalledApps() {
        availableTerminals = TerminalApp.knownTerminals.filter { terminal in
            NSWorkspace.shared.urlForApplication(withBundleIdentifier: terminal.bundleIdentifier) != nil
        }
        if availableTerminals.isEmpty {
            availableTerminals = [TerminalApp.knownTerminals[0]] // 系统终端总是可用
        }

        availableEditors = EditorApp.knownEditors.filter { editor in
            NSWorkspace.shared.urlForApplication(withBundleIdentifier: editor.bundleIdentifier) != nil
        }
        if availableEditors.isEmpty {
            availableEditors = [EditorApp.knownEditors[0]] // 文本编辑总是可用
        }
    }
}

// MARK: - 关于 Tab

struct AboutTab: View {
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // 应用图标
            Image(systemName: "contextualmenu.and.cursorarrow")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)

            // 名称与版本
            VStack(spacing: 4) {
                Text("FinderRight")
                    .font(.title)
                    .fontWeight(.bold)

                Text("版本 \(appVersion) (\(buildNumber))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // 描述
            Text("增强 macOS Finder 右键菜单的强大工具。\n快速访问开发工具、文件操作和自定义动作。")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .font(.body)
                .padding(.horizontal, 40)

            // GitHub 链接
            Link(destination: URL(string: "https://github.com/nicekid1/FinderRight")!) {
                HStack(spacing: 6) {
                    Image(systemName: "link")
                    Text("GitHub 仓库")
                }
                .font(.callout)
            }
            .buttonStyle(.plain)
            .foregroundColor(.accentColor)

            Spacer()

            // 版权信息
            Text("Copyright © 2026 FinderRight. All rights reserved.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
