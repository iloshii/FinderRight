import Foundation

// MARK: - Action 注册中心

/// 管理所有 FinderAction 的注册中心
public final class ActionRegistry {

    /// 单例
    public static let shared = ActionRegistry()

    /// 已注册的 actions
    private var registeredActions: [FinderAction] = []

    private init() {}

    // MARK: - 注册

    /// 注册一个 Action
    public func registerAction(_ action: FinderAction) {
        // 避免重复注册
        guard !registeredActions.contains(where: { $0.id == action.id }) else { return }
        registeredActions.append(action)
    }

    /// 批量注册 Actions
    public func registerActions(_ actions: [FinderAction]) {
        for action in actions {
            registerAction(action)
        }
    }

    // MARK: - 查询

    /// 获取指定分类的所有 actions
    public func actions(for category: ActionCategory) -> [FinderAction] {
        return registeredActions.filter { $0.category == category }
    }

    /// 获取所有已注册的 actions
    public func allActions() -> [FinderAction] {
        return registeredActions
    }

    /// 获取指定分类中已启用且可用的 actions
    public func enabledActions(for category: ActionCategory) -> [FinderAction] {
        let config = SharedConfig.shared
        return actions(for: category).filter { action in
            action.isAvailable && config.isActionEnabled(action.id)
        }
    }

    /// 获取所有已启用且可用的 actions
    public func allEnabledActions() -> [FinderAction] {
        let config = SharedConfig.shared
        return registeredActions.filter { action in
            action.isAvailable && config.isActionEnabled(action.id)
        }
    }

    // MARK: - 查找

    /// 根据 id 查找 action
    public func action(withId id: String) -> FinderAction? {
        return registeredActions.first { $0.id == id }
    }

    // MARK: - 重置

    /// 清空所有已注册的 actions
    public func reset() {
        registeredActions.removeAll()
    }

    // MARK: - 注册内置 Actions

    /// 注册所有内置 Actions
    public func registerBuiltinActions() {
        // 新建文件 Actions
        registerActions([
            NewTextFileAction(),
            NewMarkdownFileAction(),
            NewHTMLFileAction(),
            NewPythonFileAction(),
            NewSwiftFileAction(),
            NewJSONFileAction(),
            NewShellScriptAction(),
        ])

        // 复制路径 Actions
        registerActions([
            CopyPOSIXPathAction(),
            CopyFileURLAction(),
            CopyFileNameAction(),
            CopyFileNameWithoutExtAction(),
            CopyDirectoryPathAction(),
        ])

        // 打开终端 Actions
        registerActions([
            OpenInTerminalAction(),
            OpenInITermAction(),
            OpenInWarpAction(),
        ])

        // 打开编辑器 Actions
        registerActions([
            OpenInVSCodeAction(),
            OpenInCursorAction(),
            OpenInSublimeAction(),
            OpenInZedAction(),
        ])

        // 文件管理 Actions
        registerActions([
            CutFilesAction(),
            PasteFilesAction(),
            MoveToFolderAction(),
            CopyToFolderAction(),
            DeletePermanentlyAction(),
        ])

        // 显示设置 Actions
        registerActions([
            ToggleHiddenFilesAction(),
        ])

        // 压缩解压 Actions
        registerActions([
            CompressToZipAction(),
            DecompressHereAction(),
            DecompressToFolderAction(),
        ])
    }
}
