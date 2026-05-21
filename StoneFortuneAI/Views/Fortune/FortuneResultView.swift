import SwiftUI

struct FortuneResultView: View {
    @ObservedObject var viewModel: FortuneViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("✨")
                        .font(.system(size: 52))
                    Text("結果発表")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    Text("Your Crystal Reading Result")
                        .font(.subheadline).italic()
                        .foregroundColor(Color(hex: Constants.Colors.accent).opacity(0.8))
                    Text("あなたに響くパワーストーン")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 24)

                // 1st place — large card
                if let first = viewModel.results.first {
                    ResultCard(result: first, isLarge: true)
                        .padding(.horizontal, 20)
                }

                // 2nd and 3rd — side by side
                let rest = Array(viewModel.results.dropFirst())
                if !rest.isEmpty {
                    HStack(spacing: 12) {
                        ForEach(rest) { result in
                            ResultCard(result: result, isLarge: false)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Ad placeholder
                AdBannerSection()
                    .padding(.horizontal, 20)

                // Reset button
                Button(action: { viewModel.reset() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("もう一度占う")
                            .font(.headline.bold())
                    }
                    .foregroundColor(Color(hex: Constants.Colors.accent))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: Constants.Colors.accent).opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color(hex: Constants.Colors.accent), lineWidth: 1.5)
                    )
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - ResultCard
private struct ResultCard: View {
    let result: FortuneResult
    let isLarge: Bool

    var body: some View {
        VStack(spacing: isLarge ? 14 : 10) {
            // Rank badge
            HStack {
                Text(rankLabel)
                    .font(.caption.bold())
                    .foregroundColor(rankColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(rankColor.opacity(0.2))
                    .clipShape(Capsule())
                Spacer()
            }

            // Stone circle
            ZStack {
                Circle()
                    .fill(Color(hex: result.stone.color).opacity(0.3))
                    .frame(width: isLarge ? 90 : 60, height: isLarge ? 90 : 60)
                Circle()
                    .strokeBorder(Color(hex: result.stone.color), lineWidth: 2)
                    .frame(width: isLarge ? 90 : 60, height: isLarge ? 90 : 60)
                Text(result.stone.emoji)
                    .font(.system(size: isLarge ? 40 : 26))
            }

            Text(result.stone.nameJa)
                .font(isLarge ? .title3.bold() : .subheadline.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(result.stone.nameEn)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))

            // Stars
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { i in
                    Text(i <= result.score ? "★" : "☆")
                        .font(isLarge ? .body : .caption)
                        .foregroundColor(Color(hex: Constants.Colors.accent))
                }
            }

            // Message
            if isLarge {
                Text(result.message)
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)

                Divider()
                    .background(Color.white.opacity(0.2))

                Text(result.advice)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .italic()
            } else {
                Text(result.message)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .padding(isLarge ? 20 : 14)
        .frame(maxWidth: .infinity)
        .mysticalCard()
    }

    private var rankLabel: String {
        switch result.rank {
        case 1: return "1位 👑"
        case 2: return "2位 🥈"
        case 3: return "3位 🥉"
        default: return "\(result.rank)位"
        }
    }

    private var rankColor: Color {
        switch result.rank {
        case 1: return Color(hex: Constants.Colors.accent)
        case 2: return Color(hex: "#C0C0C0")
        case 3: return Color(hex: "#CD7F32")
        default: return .white
        }
    }
}

// MARK: - Ad Banner
struct AdBannerSection: View {
    var body: some View {
        BannerAdView()
            .frame(height: 50)
            .cornerRadius(8)
    }
}
