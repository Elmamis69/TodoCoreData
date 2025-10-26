import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false

    // lee versión y build del Info.plist
    private var versionString: String {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "Version \(v) (\(b))"
    }

    var body: some View {
        NavigationStack {
            Form {
                // Branding / App Info
                Section {
                    HStack(alignment: .center, spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                                .frame(width: 60, height: 60)

                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.primary)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tasko")
                                .font(.headline)

                            Text(versionString)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Appearance
                Section("Appearance") {
                    Toggle(isOn: $isDarkMode) {
                        Label("Dark Mode", systemImage: isDarkMode ? "moon.fill" : "sun.max.fill")
                    }
                    .onChange(of: isDarkMode) { _, _ in
                        updateAppearance()
                    }
                }

                // Support / legal
                Section("Support") {
                    Link(destination: URL(string: "https://github.com/Elmamis69/TodoCoreData/blob/main/PRIVACY.md")!) {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }

                    Link(destination: URL(string: "https://tasko.app/feedback")!) {
                        Label("Send Feedback", systemImage: "envelope")
                    }
                }

                // Footer
                Section {
                    Text("Made with ❤️ using SwiftUI + Core Data")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }

    // Forzar apariencia en runtime
    private func updateAppearance() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first else { return }

        window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }
}
