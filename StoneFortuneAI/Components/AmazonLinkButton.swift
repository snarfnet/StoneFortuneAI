import SwiftUI

struct AmazonLinkButton: View {
    let stone: Stone

    var body: some View {
        Group {
            if let url = Constants.Amazon.searchURL(query: stone.amazonSearchQuery) {
                Link(destination: url) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.body.bold())
                        Text("この石をAmazonで探す🔍")
                            .font(.body.bold())
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(hex: Constants.Colors.accent),
                                Color(hex: "#F0C040")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: Color(hex: Constants.Colors.accent).opacity(0.4),
                            radius: 8, x: 0, y: 4)
                }
            }
        }
    }
}
