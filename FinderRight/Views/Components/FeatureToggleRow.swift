import SwiftUI

struct FeatureToggleRow: View {
    let feature: FeatureItem
    @ObservedObject var sharedDefaults: SharedDefaults
    @State private var isEnabled: Bool = true

    var body: some View {
        Toggle(isOn: $isEnabled) {
            HStack(spacing: 12) {
                Image(systemName: feature.icon)
                    .font(.body)
                    .foregroundColor(.accentColor)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(feature.name)
                        .font(.body)
                    Text(feature.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            isEnabled = sharedDefaults.bool(forKey: feature.key, defaultValue: true)
        }
        .onChange(of: isEnabled) { _, newValue in
            sharedDefaults.set(newValue, forKey: feature.key)
        }
    }
}
