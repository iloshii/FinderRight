import SwiftUI

@main
struct FinderRightApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false

    var body: some Scene {
        // 菜单栏图标
        MenuBarExtra("FinderRight", systemImage: "contextualmenu.and.cursorarrow") {
            MenuBarView(showOnboarding: $showOnboarding)
        }

        // 设置窗口
        Settings {
            SettingsView()
        }

        // 首次启动 & 引导窗口
        Window("欢迎使用 FinderRight", id: "onboarding") {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                .onDisappear {
                    showOnboarding = false
                }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 600, height: 500)
    }
}
