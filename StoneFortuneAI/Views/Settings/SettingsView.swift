import SwiftUI

struct SettingsView: View {
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                List {
                    // App info section
                    Section {
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: Constants.Colors.backgroundTop),
                                                Color(hex: Constants.Colors.backgroundBottom)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .strokeBorder(Color(hex: Constants.Colors.accent).opacity(0.5), lineWidth: 1)
                                    )
                                Text("🔮")
                                    .font(.system(size: 32))
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("StoneFortuneAI")
                                    .font(.headline.bold())
                                    .foregroundColor(.white)
                                Text("パワーストーン占いアプリ")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.white.opacity(0.06))
                    }

                    // About section
                    Section("アプリについて") {
                        SettingsRow(icon: "info.circle", title: "バージョン") {
                            Text("\(appVersion) (\(buildNumber))")
                                .foregroundColor(.white.opacity(0.5))
                        }

                        SettingsRow(icon: "globe", title: "プライバシーポリシー") {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.3))
                        }

                        SettingsRow(icon: "doc.text", title: "利用規約") {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.3))
                        }

                        SettingsRow(icon: "star", title: "レビューを書く") {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// MARK: - Settings Row
private struct SettingsRow<Trailing: View>: View {
    let icon: String
    let title: String
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: Constants.Colors.accent))
                .frame(width: 24)
            Text(title)
                .foregroundColor(.white)
            Spacer()
            trailing()
        }
        .listRowBackground(Color.white.opacity(0.06))
    }
}
