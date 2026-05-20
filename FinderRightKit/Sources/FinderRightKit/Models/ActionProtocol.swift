import AppKit

// MARK: - Action 分类

/// Action 的功能分类枚举
public enum ActionCategory: String, CaseIterable, Codable {
    case newFile = "新建文件"
    case copyPath = "复制路径"
    case openTerminal = "打开终端"
    case openEditor = "打开编辑器"
    case fileOps = "文件操作"
    case visibility = "显示设置"
    case archive = "压缩解压"
}

// MARK: - Action 协议

/// Finder 右键菜单 Action 协议
public protocol FinderAction {
    /// Action 唯一标识符
    var id: String { get }
    /// Action 显示名称
    var title: String { get }
    /// Action 图标
    var icon: NSImage? { get }
    /// Action 分类
    var category: ActionCategory { get }
    /// 根据系统环境判断是否可用
    var isAvailable: Bool { get }
    /// 执行 Action
    func execute(with urls: [URL]) throws
}

public extension FinderAction {
    var isAvailable: Bool { true }
}
