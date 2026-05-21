import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            FortuneView()
                .tabItem {
                    Label("占い", systemImage: "sparkles")
                }

            DailyFortuneView()
                .tabItem {
                    Label("おみくじ", systemImage: "leaf")
                }

            StoneBookView()
                .tabItem {
                    Label("図鑑", systemImage: "book")
                }

            ChakraView()
                .tabItem {
                    Label("チャクラ", systemImage: "circle.hexagongrid.fill")
                }

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gear")
                }
        }
        .tint(Color(hex: Constants.Colors.accent))
    }
}
