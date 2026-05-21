import SwiftUI

struct StoneCard: View {
    let stone: Stone
    var score: Int? = nil
    var rank: Int? = nil
    var message: String? = nil
    var isLarge: Bool = false

    var body: some View {
        VStack(spacing: isLarge ? 12 : 8) {
            // Rank badge
            if let rank = rank {
                HStack {
                    Text(rankLabel(rank))
                        .font(.caption.bold())
                        .foregroundColor(rankColor(rank))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(rankColor(rank).opacity(0.2))
                        .clipShape(Capsule())
                    Spacer()
                }
            }

            // Stone circle + emoji
            ZStack {
                Circle()
                    .fill(Color(hex: stone.color).opacity(0.35))
                    .frame(width: isLarge ? 80 : 56, height: isLarge ? 80 : 56)
                Circle()
                    .strokeBorder(Color(hex: stone.color), lineWidth: 2)
                    .frame(width: isLarge ? 80 : 56, height: isLarge ? 80 : 56)
                Text(stone.emoji)
                    .font(.system(size: isLarge ? 38 : 26))
            }

            // Name
            Text(stone.nameJa)
                .font(isLarge ? .headline.bold() : .subheadline.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(stone.nameEn)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            // Score stars
            if let score = score {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { i in
                        Text(i <= score ? "★" : "☆")
                            .font(isLarge ? .body : .caption)
                            .foregroundColor(Color(hex: Constants.Colors.accent))
                    }
                }
            }

            // Message
            if let message = message, isLarge {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.top, 2)
            }
        }
        .padding(isLarge ? 20 : 14)
        .frame(maxWidth: .infinity)
        .mysticalCard()
    }

    private func rankLabel(_ rank: Int) -> String {
        switch rank {
        case 1: return "1位 👑"
        case 2: return "2位"
        case 3: return "3位"
        default: return "\(rank)位"
        }
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return Color(hex: Constants.Colors.accent)
        case 2: return Color(hex: "#C0C0C0")
        case 3: return Color(hex: "#CD7F32")
        default: return .white
        }
    }
}
