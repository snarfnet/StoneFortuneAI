import Foundation

struct Stone: Codable, Identifiable, Hashable {
    let id: String
    let nameJa: String
    let nameEn: String
    let emoji: String
    let color: String
    let category: String
    let zodiac: [String]
    let birthMonth: [Int]
    let chakra: String
    let element: String
    let hardness: Double
    let keywords: [String]
    let meaning: String
    let effects: [String]
    let concerns: [String]
    let compatibility: [String]
    let careMethod: String
    let amazonSearchQuery: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Stone, rhs: Stone) -> Bool {
        lhs.id == rhs.id
    }
}
