import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("App Info")) {
                    HStack {
                        Label("TodoCoreData", systemImage: "checkmark.circle")
                        Spacer()
                        Text("v1.0")
                            .foregroundStyle(.secondary)
                    }
                }

                Section(header: Text("Preferences")) {
                    Toggle(isOn: $isDarkMode) {
                        Label("Dark Mode", systemImage: isDarkMode ? "moon.fill" : "sun.max.fill")
                    }
                    // ✅ Nuevo formato (iOS 17 compatible)
                    .onChange(of: isDarkMode) { _, _ in
                        updateAppearance()
                    }
                }

                Section(header: Text("Support")) {
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }
                    Link(destination: URL(string: "https://example.com/feedback")!) {
                        Label("Send Feedback", systemImage: "envelope")
                    }
                }

                Section {
                    Text("Made with ❤️ using SwiftUI + Core Data")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }

    // ✅ Función moderna para actualizar modo oscuro
    private func updateAppearance() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first else { return }

        window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }
}
