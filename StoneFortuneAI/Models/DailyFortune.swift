import Foundation

enum FortuneLuck: String, CaseIterable {
    case daikichi = "大吉"
    case kichi = "吉"
    case chukichi = "中吉"
    case shokichi = "小吉"
    case suekichi = "末吉"

    var weight: Int {
        switch self {
        case .daikichi: return 10
        case .kichi: return 25
        case .chukichi: return 30
        case .shokichi: return 20
        case .suekichi: return 15
        }
    }

    var emoji: String {
        switch self {
        case .daikichi: return "🌟"
        case .kichi: return "⭐"
        case .chukichi: return "✨"
        case .shokichi: return "🌙"
        case .suekichi: return "💫"
        }
    }

    var color: String {
        switch self {
        case .daikichi: return "#FFD700"
        case .kichi: return "#FFA500"
        case .chukichi: return "#9B59B6"
        case .shokichi: return "#3498DB"
        case .suekichi: return "#95A5A6"
        }
    }

    var message: String {
        switch self {
        case .daikichi: return "最高の運気！何事も前向きに取り組む日。"
        case .kichi: return "良い流れが続いています。チャンスを掴んで。"
        case .chukichi: return "着実に進む日。丁寧な行動が実を結ぶ。"
        case .shokichi: return "穏やかな運気。小さな幸せを大切に。"
        case .suekichi: return "今は準備の時。焦らず積み重ねよう。"
        }
    }
}

struct DailyFortune: Identifiable {
    let id = UUID()
    let stone: Stone
    let luck: FortuneLuck
    let luckyColor: String
    let luckyNumber: Int
    let luckyColorName: String
    let advice: String
    let date: Date
}

let luckyColors: [(name: String, hex: String)] = [
    ("ゴールド", "#FFD700"),
    ("ラベンダー", "#E6E6FA"),
    ("ローズピンク", "#FF69B4"),
    ("ミントグリーン", "#98FF98"),
    ("スカイブルー", "#87CEEB"),
    ("コーラル", "#FF7F50"),
    ("アイボリー", "#FFFFF0"),
    ("パープル", "#9B59B6"),
    ("ティール", "#008080"),
    ("サーモン", "#FA8072"),
    ("シルバー", "#C0C0C0"),
    ("インディゴ", "#4B0082"),
    ("エメラルド", "#50C878"),
    ("アンバー", "#FFBF00"),
    ("ホワイト", "#FFFFFF")
]
