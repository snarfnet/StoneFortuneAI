import SwiftUI

class StoneBookViewModel: ObservableObject {
    @Published var stones: [Stone] = []
    @Published var searchText = ""
    @Published var selectedCategory: String? = nil

    var categories: [String] {
        var seen = Set<String>()
        return stones.compactMap { stone in
            guard !seen.contains(stone.category) else { return nil }
            seen.insert(stone.category)
            return stone.category
        }
    }

    var filteredStones: [Stone] {
        stones.filter { stone in
            let matchesCategory = selectedCategory == nil || stone.category == selectedCategory
            let matchesSearch = searchText.isEmpty ||
                stone.nameJa.localizedCaseInsensitiveContains(searchText) ||
                stone.nameEn.localizedCaseInsensitiveContains(searchText) ||
                stone.keywords.contains(where: { $0.localizedCaseInsensitiveContains(searchText) }) ||
                stone.category.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }

    init() { loadStones() }

    private func loadStones() {
        guard let url = Bundle.main.url(forResource: "stones", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Stone].self, from: data) else { return }
        stones = decoded
    }
}
