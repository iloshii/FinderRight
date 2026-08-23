import Foundation

/// 一个已知的编辑器应用。
public struct KnownEditor: Identifiable, Equatable {
    /// bundle identifier，同时作为 Identifiable 的 id
    public let id: String
    /// 显示名（品牌名，不本地化）
    public let name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

/// 已知编辑器清单 —— 右键「打开编辑器」子菜单的数据源（单一事实来源）。
///
/// `all` 的顺序即子菜单展示顺序：Zed 置顶为首选默认。
/// 展示前双重过滤：NSWorkspace 已安装检测 + 用户在设置「终端 / 编辑器」页的勾选
/// （SharedConfig.isEditorEnabled，未设置时默认勾选，向后兼容）。
public enum EditorCatalog {
    public static let all: [KnownEditor] = [
        KnownEditor(id: "dev.zed.Zed",                   name: "Zed"),
        KnownEditor(id: "com.microsoft.VSCode",          name: "Visual Studio Code"),
        KnownEditor(id: "com.todesktop.230313mzl4w4u92", name: "Cursor"),
        KnownEditor(id: "com.sublimetext.4",             name: "Sublime Text"),
        KnownEditor(id: "com.apple.dt.Xcode",            name: "Xcode"),
        KnownEditor(id: "com.panic.Nova",                name: "Nova"),
        KnownEditor(id: "com.barebones.bbedit",          name: "BBEdit"),
        KnownEditor(id: "com.apple.TextEdit",            name: "TextEdit"),
        // JetBrains 全家桶（九大 IDE，含 IDEA/PyCharm 的 CE 变体）。
        // bundle id 大小写系各产品历史不一致；写错只会因"未安装"被过滤隐藏，不影响路径正确性。
        KnownEditor(id: "com.jetbrains.intellij",         name: "IntelliJ IDEA"),
        KnownEditor(id: "com.jetbrains.intellij.ce",      name: "IntelliJ IDEA CE"),
        KnownEditor(id: "com.jetbrains.pycharm",          name: "PyCharm"),
        KnownEditor(id: "com.jetbrains.pycharm.ce",       name: "PyCharm CE"),
        KnownEditor(id: "com.jetbrains.WebStorm",         name: "WebStorm"),
        KnownEditor(id: "com.jetbrains.PhpStorm",         name: "PhpStorm"),
        KnownEditor(id: "com.jetbrains.goland",           name: "GoLand"),
        KnownEditor(id: "com.jetbrains.CLion",            name: "CLion"),
        KnownEditor(id: "com.jetbrains.datagrip",         name: "DataGrip"),
        KnownEditor(id: "com.jetbrains.rubymine",         name: "RubyMine"),
        KnownEditor(id: "com.jetbrains.rider",            name: "Rider"),
    ]
}
