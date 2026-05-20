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

            // 功能按钮
            Button {
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

            Button {
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

    private func openSettings() {
        if #available(macOS 14.0, *) {
            NSApp.activate()
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }
}
