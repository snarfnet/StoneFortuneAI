import Foundation

struct FortuneResult: Identifiable {
    let id = UUID()
    let stone: Stone
    let score: Int          // 1-5
    let message: String
    let advice: String
    let rank: Int           // 1, 2, 3
}

struct FortuneInput {
    var birthDate: Date = Calendar.current.date(from: DateComponents(year: 1990, month: 1, day: 1)) ?? Date()
    var concern: ConcernCategory = .overall
    var name: String = ""
}

enum ConcernCategory: String, CaseIterable, Identifiable {
    case love = "恋愛"
    case work = "仕事"
    case health = "健康"
    case money = "金運"
    case relationship = "人間関係"
    case study = "学業"
    case family = "家庭"
    case overall = "全体運"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .love: return "💕"
        case .work: return "💼"
        case .health: return "🌿"
        case .money: return "💰"
        case .relationship: return "🤝"
        case .study: return "📚"
        case .family: return "🏠"
        case .overall: return "✨"
        }
    }

    var keywords: [String] {
        switch self {
        case .love: return ["恋愛", "愛情", "結婚", "パートナー", "魅力", "縁結び", "ロマンス", "恋"]
        case .work: return ["仕事", "キャリア", "成功", "集中力", "決断力", "行動力", "目標", "達成"]
        case .health: return ["健康", "体力", "免疫力", "活力", "癒し", "回復", "エネルギー", "バランス"]
        case .money: return ["金運", "財運", "豊かさ", "繁栄", "幸運", "引き寄せ", "豊穣", "富"]
        case .relationship: return ["人間関係", "コミュニケーション", "友情", "調和", "信頼", "絆", "協調"]
        case .study: return ["学業", "集中力", "記憶力", "知恵", "直感力", "思考力", "創造性", "理解力"]
        case .family: return ["家庭", "家族", "絆", "安心", "平和", "守護", "子育て", "安定"]
        case .overall: return ["全体運", "幸運", "浄化", "守護", "開運", "バランス", "エネルギー", "調和"]
        }
    }
}
