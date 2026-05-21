import SwiftUI

class DailyFortuneViewModel: ObservableObject {
    @Published var fortune: DailyFortune?
    @Published var hasDrawnToday = false
    @Published var isRevealing = false

    private var stones: [Stone] = []

    init() {
        loadStones()
        checkTodayStatus()
    }

    // MARK: - Public

    func drawFortune() {
        guard !stones.isEmpty, !hasDrawnToday else { return }

        let today = todayDateString()
        let seed = dateSeed(from: today)
        var rng = SeededRNG(seed: seed)

        // 石をシード値で選択（同日同結果）
        let stoneIndex = Int(rng.next() % UInt64(stones.count))
        let stone = stones[stoneIndex]

        // luckをweightedで選択
        let luck = weightedLuck(rng: &rng)

        // ラッキーカラーを選択
        let colorIndex = Int(rng.next() % UInt64(luckyColors.count))
        let color = luckyColors[colorIndex]

        // ラッキーナンバーを選択（1〜9）
        let luckyNumber = Int(rng.next() % 9) + 1

        let advice = generateAdvice(stone: stone, luck: luck)

        let newFortune = DailyFortune(
            stone: stone,
            luck: luck,
            luckyColor: color.hex,
            luckyNumber: luckyNumber,
            luckyColorName: color.name,
            advice: advice,
            date: Date()
        )

        // UserDefaultsに保存
        let defaults = UserDefaults.standard
        defaults.set(today, forKey: Constants.UserDefaultsKeys.lastDailyFortuneDate)
        defaults.set(stone.id, forKey: Constants.UserDefaultsKeys.lastDailyFortuneStoneID)
        defaults.set(luck.rawValue, forKey: Constants.UserDefaultsKeys.lastDailyFortuneLuck)
        defaults.set(color.hex, forKey: Constants.UserDefaultsKeys.lastDailyFortuneLuckyColor)
        defaults.set(luckyNumber, forKey: Constants.UserDefaultsKeys.lastDailyFortuneLuckyNumber)

        fortune = newFortune
        hasDrawnToday = true

        // アニメーション演出
        isRevealing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isRevealing = false
        }
    }

    func shareText() -> String {
        guard let f = fortune else { return "" }
        return """
        🔮 今日の石占い
        \(f.luck.emoji) 運勢: \(f.luck.rawValue)
        💎 守護石: \(f.stone.nameJa)（\(f.stone.emoji)）
        🍀 ラッキーカラー: \(f.luckyColorName)
        🔢 ラッキーナンバー: \(f.luckyNumber)
        ✨ \(f.advice)
        #石占い #パワーストーン #\(f.stone.nameJa)
        """
    }

    // MARK: - Private

    private func loadStones() {
        guard let url = Bundle.main.url(forResource: "stones", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Stone].self, from: data) else { return }
        stones = decoded
    }

    private func checkTodayStatus() {
        let defaults = UserDefaults.standard
        let today = todayDateString()
        guard let savedDate = defaults.string(forKey: Constants.UserDefaultsKeys.lastDailyFortuneDate),
              savedDate == today else {
            hasDrawnToday = false
            return
        }

        // 保存済みデータを復元
        guard let stoneID = defaults.string(forKey: Constants.UserDefaultsKeys.lastDailyFortuneStoneID),
              let stone = stones.first(where: { $0.id == stoneID }),
              let luckRaw = defaults.string(forKey: Constants.UserDefaultsKeys.lastDailyFortuneLuck),
              let luck = FortuneLuck(rawValue: luckRaw) else {
            hasDrawnToday = false
            return
        }

        let colorHex = defaults.string(forKey: Constants.UserDefaultsKeys.lastDailyFortuneLuckyColor) ?? luckyColors[0].hex
        let luckyNumber = defaults.integer(forKey: Constants.UserDefaultsKeys.lastDailyFortuneLuckyNumber)
        let colorName = luckyColors.first(where: { $0.hex == colorHex })?.name ?? luckyColors[0].name
        let advice = generateAdvice(stone: stone, luck: luck)

        fortune = DailyFortune(
            stone: stone,
            luck: luck,
            luckyColor: colorHex,
            luckyNumber: luckyNumber == 0 ? 1 : luckyNumber,
            luckyColorName: colorName,
            advice: advice,
            date: Date()
        )
        hasDrawnToday = true
    }

    private func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func dateSeed(from dateString: String) -> UInt64 {
        // 日付文字列から決定論的シード値を生成
        let digits = dateString.compactMap { $0.wholeNumberValue }
        let combined = digits.enumerated().reduce(UInt64(0)) { acc, pair in
            acc &+ UInt64(pair.element) &* UInt64(pair.offset + 1) &* 31
        }
        return combined &+ 12345
    }

    private func weightedLuck(rng: inout SeededRNG) -> FortuneLuck {
        let total = FortuneLuck.allCases.reduce(0) { $0 + $1.weight }
        var roll = Int(rng.next() % UInt64(total))
        for luck in FortuneLuck.allCases {
            roll -= luck.weight
            if roll < 0 { return luck }
        }
        return .chukichi
    }

    private func generateAdvice(stone: Stone, luck: FortuneLuck) -> String {
        let name = stone.nameJa
        switch luck {
        case .daikichi:
            return "\(name)の力が最高潮に達しています。今日は大きな決断や挑戦に最適な日。積極的に行動して吉。"
        case .kichi:
            return "\(name)があなたを明るい方向へ導いています。人との縁を大切にすると良いことが起きるでしょう。"
        case .chukichi:
            return "\(name)のエネルギーが安定しています。コツコツと取り組むことが実を結ぶ日です。"
        case .shokichi:
            return "\(name)の穏やかな波動が心を落ち着かせます。無理をせず、自分のペースで過ごしましょう。"
        case .suekichi:
            return "\(name)を傍に置き、今日は内省と準備の日と考えましょう。明日の大きな運気の上昇に備えて。"
        }
    }
}

// MARK: - Seeded RNG (線形合同法)

private struct SeededRNG {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 1 : seed
    }

    mutating func next() -> UInt64 {
        // xorshift64
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
