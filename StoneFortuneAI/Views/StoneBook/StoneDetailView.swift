import SwiftUI

struct StoneDetailView: View {
    let stone: Stone

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView {
                VStack(spacing: 24) {
                    // Hero section
                    VStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: stone.color).opacity(0.25))
                                .frame(width: 130, height: 130)
                            Circle()
                                .strokeBorder(Color(hex: stone.color), lineWidth: 3)
                                .frame(width: 130, height: 130)
                            Text(stone.emoji)
                                .font(.system(size: 60))
                        }
                        .shadow(color: Color(hex: stone.color).opacity(0.4), radius: 20, x: 0, y: 8)

                        Text(stone.nameJa)
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        Text(stone.nameEn)
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.6))

                        // Category + element badges
                        HStack(spacing: 8) {
                            InfoBadge(text: stone.chakra, icon: "circle.hexagongrid")
                            InfoBadge(text: stone.element, icon: "leaf")
                            InfoBadge(text: "硬度 \(String(format: "%.1f", stone.hardness))", icon: "diamond")
                        }
                    }
                    .padding(.top, 8)

                    // Meaning
                    DetailSection(title: "意味・概要", icon: "book.closed") {
                        Text(stone.meaning)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Effects
                    DetailSection(title: "効能", icon: "sparkles") {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(stone.effects, id: \.self) { effect in
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(hex: Constants.Colors.accent))
                                        .font(.caption)
                                    Text(effect)
                                        .font(.body)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Keywords
                    DetailSection(title: "キーワード", icon: "tag") {
                        FlowLayout(spacing: 8) {
                            ForEach(stone.keywords, id: \.self) { keyword in
                                KeywordChip(text: keyword)
                            }
                        }
                    }

                    // Compatible stones
                    if !stone.compatibility.isEmpty {
                        DetailSection(title: "相性の良い石", icon: "heart.fill") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(stone.compatibility, id: \.self) { stoneId in
                                        CompatibilityChip(stoneId: stoneId)
                                    }
                                }
                            }
                        }
                    }

                    // Care method
                    DetailSection(title: "お手入れ方法", icon: "drop") {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "info.circle")
                                .foregroundColor(Color(hex: Constants.Colors.accent))
                                .font(.body)
                                .padding(.top, 2)
                            Text(stone.careMethod)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Amazon link
                    AmazonLinkButton(stone: stone)
                        .padding(.horizontal, 20)

                    // Ad placeholder
                    AdBannerSection()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle(stone.nameJa)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Detail Section
private struct DetailSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.subheadline.bold())
                .foregroundColor(Color(hex: Constants.Colors.accent))

            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .mysticalCard()
    }
}

// MARK: - Info Badge
private struct InfoBadge: View {
    let text: String
    let icon: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption.bold())
            .foregroundColor(.white.opacity(0.8))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.1))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Keyword Chip
private struct KeywordChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.bold())
            .foregroundColor(Color(hex: Constants.Colors.accent))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(hex: Constants.Colors.accent).opacity(0.15))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color(hex: Constants.Colors.accent).opacity(0.4), lineWidth: 1)
            )
    }
}

// MARK: - Compatibility Chip
private struct CompatibilityChip: View {
    let stoneId: String

    var body: some View {
        Text(stoneId.replacingOccurrences(of: "_", with: " ").capitalized)
            .font(.caption.bold())
            .foregroundColor(.white.opacity(0.8))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.1))
            .clipShape(Capsule())
    }
}

// MARK: - Flow Layout (wrapping chip layout)
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0 }
                        .reduce(0) { $0 + $1 + spacing } - spacing
        return CGSize(width: proposal.width ?? 0, height: max(0, height))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        let maxWidth = proposal.width ?? 0
        var rows: [[LayoutSubview]] = [[]]
        var currentRowWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentRowWidth + size.width > maxWidth, !rows[rows.count - 1].isEmpty {
                rows.append([])
                currentRowWidth = 0
            }
            rows[rows.count - 1].append(subview)
            currentRowWidth += size.width + spacing
        }
        return rows
    }
}
