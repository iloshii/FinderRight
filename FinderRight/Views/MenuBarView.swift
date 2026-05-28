import SwiftUI

struct MenuBarView: View {
    @Binding var showOnboarding: Bool
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            // 状态显示
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("FinderRight 运行中")
                    .font(.headline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider()

            // 设置按钮
            SettingsButtonView()

            Button {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "onboarding")
            } label: {
                HStack {
                    Image(systemName: "hand.wave")
                    Text("引导设置")
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)

            Divider()

            // 退出按钮
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                HStack {
                    Image(systemName: "power")
                    Text("退出 FinderRight")
                    Spacer()
                    Text("⌘Q")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .keyboardShortcut("q", modifiers: .command)
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
        .padding(.vertical, 6)
        .frame(width: 240)
    }
}

// 单独的 View 处理 openSettings，避免 @available 污染整个结构体
@available(macOS 14.0, *)
private struct SettingsButtonWithEnv: View {
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        Button {
            NSApp.activate(ignoringOtherApps: true)
            openSettings()
        } label: {
            HStack {
                Image(systemName: "gearshape")
                Text("设置...")
                Spacer()
                Text("⌘,")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .keyboardShortcut(",", modifiers: .command)
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}

private struct SettingsButtonView: View {
    var body: some View {
        if #available(macOS 14.0, *) {
            SettingsButtonWithEnv()
        } else {
            Button {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
            } label: {
                HStack {
                    Image(systemName: "gearshape")
                    Text("设置...")
                    Spacer()
                    Text("⌘,")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .keyboardShortcut(",", modifiers: .command)
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }
}
