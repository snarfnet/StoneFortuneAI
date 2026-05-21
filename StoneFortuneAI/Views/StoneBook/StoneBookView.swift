import SwiftUI

struct StoneBookView: View {
    @StateObject private var viewModel = StoneBookViewModel()

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.5))
                        TextField("石の名前やキーワードで検索", text: $viewModel.searchText)
                            .foregroundColor(.white)
                            .tint(Color(hex: Constants.Colors.accent))
                        if !viewModel.searchText.isEmpty {
                            Button(action: { viewModel.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        }
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                    // Category filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            CategoryChip(
                                label: "すべて",
                                isSelected: viewModel.selectedCategory == nil
                            ) {
                                viewModel.selectedCategory = nil
                            }
                            ForEach(viewModel.categories, id: \.self) { category in
                                CategoryChip(
                                    label: categoryDisplayName(category),
                                    isSelected: viewModel.selectedCategory == category
                                ) {
                                    viewModel.selectedCategory =
                                        viewModel.selectedCategory == category ? nil : category
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }

                    // Stone grid
                    if viewModel.filteredStones.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Text("🔍")
                                .font(.system(size: 48))
                            Text("石が見つかりませんでした")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(viewModel.filteredStones) { stone in
                                    NavigationLink(destination: StoneDetailView(stone: stone)) {
                                        StoneGridCell(stone: stone)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
            .navigationTitle("石図鑑 💎")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func categoryDisplayName(_ raw: String) -> String {
        let map: [String: String] = [
            "quartz": "クォーツ",
            "tourmaline": "トルマリン",
            "feldspar": "長石",
            "metamorphic": "変成岩",
            "volcanic": "火山岩",
            "oxide": "酸化鉱物",
            "carbonate": "炭酸塩",
            "sulfate": "硫酸塩"
        ]
        return map[raw] ?? raw
    }
}

// MARK: - Category Chip
private struct CategoryChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.bold())
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    isSelected
                        ? Color(hex: Constants.Colors.accent)
                        : Color.white.opacity(0.12)
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(
                            isSelected ? Color.clear : Color.white.opacity(0.2),
                            lineWidth: 1
                        )
                )
        }
    }
}

// MARK: - Stone Grid Cell
private struct StoneGridCell: View {
    let stone: Stone

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color(hex: stone.color).opacity(0.3))
                    .frame(width: 64, height: 64)
                Circle()
                    .strokeBorder(Color(hex: stone.color), lineWidth: 1.5)
                    .frame(width: 64, height: 64)
                Text(stone.emoji)
                    .font(.system(size: 30))
            }

            Text(stone.nameJa)
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(stone.nameEn)
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
                .lineLimit(1)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .mysticalCard()
    }
}
