import Foundation

// MARK: - 文件模板

/// 自定义文件模板
public struct FileTemplate: Codable, Equatable, Identifiable {
    public var id: String
    public var name: String
    public var fileExtension: String
    public var content: String

    public init(id: String = UUID().uuidString, name: String, fileExtension: String, content: String) {
        self.id = id
        self.name = name
        self.fileExtension = fileExtension
        self.content = content
    }
}

// MARK: - App Group 配置管理

/// App Group UserDefaults 共享配置管理器
public final class SharedConfig {

    /// App Group identifier
    public static let appGroupID = "group.com.finderright.shared"

    /// 单例
    public static let shared = SharedConfig()

    /// App Group UserDefaults
    private let defaults: UserDefaults

    private enum Keys {
        static let enabledActions = "enabledActions"
        static let preferredTerminal = "preferredTerminal"
        static let preferredEditor = "preferredEditor"
        static let customFileTemplates = "customFileTemplates"
        static let showHiddenFiles = "showHiddenFiles"
    }

    private init() {
        if let groupDefaults = UserDefaults(suiteName: SharedConfig.appGroupID) {
            self.defaults = groupDefaults
        } else {
            // Fallback to standard UserDefaults if App Group is not available
            self.defaults = UserDefaults.standard
        }
    }

    // MARK: - Enabled Actions

    /// 每个 action 的开关状态，key 为 action id
    public var enabledActions: [String: Bool] {
        get {
            defaults.dictionary(forKey: Keys.enabledActions) as? [String: Bool] ?? [:]
        }
        set {
            defaults.set(newValue, forKey: Keys.enabledActions)
        }
    }

    /// 检查指定 action 是否启用（默认为启用）
    public func isActionEnabled(_ actionId: String) -> Bool {
        return enabledActions[actionId] ?? true
    }

    /// 设置指定 action 的启用状态
    public func setActionEnabled(_ actionId: String, enabled: Bool) {
        var current = enabledActions
        current[actionId] = enabled
        enabledActions = current
    }

    // MARK: - Preferred Terminal

    /// 首选终端应用 bundle identifier
    public var preferredTerminal: String {
        get {
            defaults.string(forKey: Keys.preferredTerminal) ?? "com.apple.Terminal"
        }
        set {
            defaults.set(newValue, forKey: Keys.preferredTerminal)
        }
    }

    // MARK: - Preferred Editor

    /// 首选编辑器应用 bundle identifier
    public var preferredEditor: String {
        get {
            defaults.string(forKey: Keys.preferredEditor) ?? "com.microsoft.VSCode"
        }
        set {
            defaults.set(newValue, forKey: Keys.preferredEditor)
        }
    }

    // MARK: - Custom File Templates

    /// 自定义文件模板列表
    public var customFileTemplates: [FileTemplate] {
        get {
            guard let data = defaults.data(forKey: Keys.customFileTemplates) else { return [] }
            return (try? JSONDecoder().decode([FileTemplate].self, from: data)) ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Keys.customFileTemplates)
            }
        }
    }

    /// 添加自定义文件模板
    public func addFileTemplate(_ template: FileTemplate) {
        var templates = customFileTemplates
        templates.append(template)
        customFileTemplates = templates
    }

    /// 删除自定义文件模板
    public func removeFileTemplate(withId id: String) {
        var templates = customFileTemplates
        templates.removeAll { $0.id == id }
        customFileTemplates = templates
    }

    // MARK: - Show Hidden Files

    /// 是否显示隐藏文件
    public var showHiddenFiles: Bool {
        get {
            defaults.bool(forKey: Keys.showHiddenFiles)
        }
        set {
            defaults.set(newValue, forKey: Keys.showHiddenFiles)
        }
    }

    // MARK: - Reset

    /// 重置所有配置为默认值
    public func resetToDefaults() {
        defaults.removeObject(forKey: Keys.enabledActions)
        defaults.removeObject(forKey: Keys.preferredTerminal)
        defaults.removeObject(forKey: Keys.preferredEditor)
        defaults.removeObject(forKey: Keys.customFileTemplates)
        defaults.removeObject(forKey: Keys.showHiddenFiles)
    }
}
