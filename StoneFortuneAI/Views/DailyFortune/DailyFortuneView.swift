import SwiftUI

struct DailyFortuneView: View {
    @StateObject private var viewModel = DailyFortuneViewModel()

    var body: some View {
        ZStack {
            GradientBackground()

            if viewModel.hasDrawnToday, let fortune = viewModel.fortune {
                DailyFortuneResultView(fortune: fortune, viewModel: viewModel)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                DailyFortuneDrawView(viewModel: viewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: viewModel.hasDrawnToday)
    }
}

// MARK: - Draw View (before drawing)
private struct DailyFortuneDrawView: View {
    @ObservedObject var viewModel: DailyFortuneViewModel
    @State private var isGlowing = false

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 10) {
                Text("🎋")
                    .font(.system(size: 72))
                Text("今日のおみくじ")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                Text("毎日一回、あなたの守護石を占います")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }

            // Draw button with pulse animation
            Button(action: { viewModel.drawFortune() }) {
                VStack(spacing: 12) {
                    Text("🎋")
                        .font(.system(size: 52))
                    Text(viewModel.isRevealing ? "占い中..." : "おみくじを引く🎋")
                        .font(.title3.bold())
                        .foregroundColor(.black)
                }
                .frame(width: 200, height: 200)
                .background(
                    LinearGradient(
                        colors: [
                            Color(hex: Constants.Colors.accent),
                            Color(hex: "#F0C040")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(
                    color: Color(hex: Constants.Colors.accent).opacity(isGlowing ? 0.8 : 0.3),
                    radius: isGlowing ? 30 : 12,
                    x: 0, y: 0
                )
                .scaleEffect(isGlowing ? 1.05 : 1.0)
            }
            .disabled(viewModel.isRevealing)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    isGlowing = true
                }
            }

            Text("今日はまだおみくじを引いていません")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(32)
    }
}

// MARK: - Result View (after drawing)
private struct DailyFortuneResultView: View {
    let fortune: DailyFortune
    @ObservedObject var viewModel: DailyFortuneViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                // Header
                VStack(spacing: 6) {
                    Text(fortune.luck.emoji + " " + fortune.luck.rawValue)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(hex: fortune.luck.color))
                    Text("今日の運勢")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 24)

                // Guardian stone card
                VStack(spacing: 16) {
                    Text("今日の守護石")
                        .font(.caption.bold())
                        .foregroundColor(Color(hex: Constants.Colors.accent))
                        .textCase(.uppercase)

                    ZStack {
                        Circle()
                            .fill(Color(hex: fortune.stone.color).opacity(0.3))
                            .frame(width: 100, height: 100)
                        Circle()
                            .strokeBorder(Color(hex: fortune.stone.color), lineWidth: 2.5)
                            .frame(width: 100, height: 100)
                        Text(fortune.stone.emoji)
                            .font(.system(size: 48))
                    }

                    Text(fortune.stone.nameJa)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text(fortune.stone.nameEn)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .mysticalCard()
                .padding(.horizontal, 20)

                // Lucky info row
                HStack(spacing: 12) {
                    LuckyInfoCard(
                        title: "ラッキーカラー",
                        value: fortune.luckyColorName,
                        accent: fortune.luckyColor,
                        icon: "paintpalette"
                    )
                    LuckyInfoCard(
                        title: "ラッキーナンバー",
                        value: "\(fortune.luckyNumber)",
                        accent: Constants.Colors.accent,
                        icon: "number"
                    )
                }
                .padding(.horizontal, 20)

                // Luck message
                VStack(alignment: .leading, spacing: 8) {
                    Label("今日のメッセージ", systemImage: "quote.bubble")
                        .font(.caption.bold())
                        .foregroundColor(Color(hex: Constants.Colors.accent))
                    Text(fortune.luck.message)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .mysticalCard()
                .padding(.horizontal, 20)

                // Advice
                VStack(alignment: .leading, spacing: 8) {
                    Label("アドバイス", systemImage: "lightbulb")
                        .font(.caption.bold())
                        .foregroundColor(Color(hex: Constants.Colors.accent))
                    Text(fortune.advice)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .mysticalCard()
                .padding(.horizontal, 20)

                // Share button
                ShareLink(
                    item: viewModel.shareText(),
                    subject: Text("今日の石占い"),
                    message: Text("StoneFortuneAIで占いました✨")
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("結果をシェアする")
                            .font(.headline.bold())
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(14)
                }
                .padding(.horizontal, 20)

                // Ad placeholder
                AdBannerSection()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - Lucky Info Card
private struct LuckyInfoCard: View {
    let title: String
    let value: String
    let accent: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color(hex: accent))
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .mysticalCard()
    }
}
