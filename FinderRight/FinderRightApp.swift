import SwiftUI

@main
struct FinderRightApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("showMenuBarIcon") private var showMenuBarIcon = true
    @State private var showOnboarding = false

    // 用 AppDelegate 接收 URL scheme + 启动时配置 activation policy
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    init() {
        NSLog("[FinderRightApp] init() called, starting IPC watcher")
        IPCWatcher.shared.start()
        NSLog("[FinderRightApp] IPC watcher ready")
    }

    var body: some Scene {
        // 用 isInserted 绑定开关 —— 关闭时菜单栏不显示图标
        // 注意：MenuBarExtra 即使 isInserted=false 也仍然存在，只是 UI 不可见，
        // 这保证了能随时切回来。
        MenuBarExtra(isInserted: $showMenuBarIcon) {
            MenuBarView(showOnboarding: $showOnboarding)
        } label: {
            Image("MenuBarIcon")
        }

        Settings {
            SettingsView()
        }

        Window("欢迎使用 FinderRight", id: "onboarding") {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                .onDisappear { showOnboarding = false }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 600, height: 500)
        // Window 不响应外部 URL 事件 —— 防止 IPC 用的 finderright:// URL 错误地激活引导窗口
        .handlesExternalEvents(matching: [])
    }
}

// MARK: - AppDelegate

final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 应用启动时根据用户偏好设置 Dock 图标显隐
        // .regular   = 显示 Dock 图标 + 可被 Cmd-Tab 切换
        // .accessory = 不显示 Dock 图标，纯菜单栏 App
        // LSUIElement=YES 已保证启动时无程序坞图标；用户明确开启时才切换为 .regular
        let showDockIcon = UserDefaults.standard.object(forKey: "showDockIcon") as? Bool ?? false
        if showDockIcon {
            NSApp.setActivationPolicy(.regular)
        }
        NSLog("[AppDelegate] activation policy = \(showDockIcon ? "regular" : "accessory")")
    }

    /// 处理 finderright:// URL scheme（IPC 唤醒入口）
    func application(_ application: NSApplication, open urls: [URL]) {
        NSLog("[AppDelegate] application(open:) urls=\(urls)")
        for url in urls {
            IPCWatcher.shared.handle(url: url)
        }
    }
}
