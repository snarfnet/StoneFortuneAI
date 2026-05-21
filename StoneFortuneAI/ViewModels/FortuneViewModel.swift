import SwiftUI

class FortuneViewModel: ObservableObject {
    @Published var input = FortuneInput()
    @Published var results: [FortuneResult] = []
    @Published var showResult = false

    private var stones: [Stone] = []

    init() { loadStones() }

    private func loadStones() {
        guard let url = Bundle.main.url(forResource: "stones", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Stone].self, from: data) else { return }
        stones = decoded
    }

    func performFortune() {
        guard !stones.isEmpty else { return }

        let calendar = Calendar.current
        let birthMonth = calendar.component(.month, from: input.birthDate)
        let birthMonthValue = calendar.component(.month, from: input.birthDate)
        let zodiacSign = zodiacFrom(date: input.birthDate)
        let concernKeywords = input.concern.keywords

        var scored: [(stone: Stone, score: Int)] = stones.map { stone in
            var score = 0

            // キーワードマッチング（悩みカテゴリ ↔ stone.keywords）
            let stoneKeywordSet = Set(stone.keywords)
            let matchCount = concernKeywords.filter { stoneKeywordSet.contains($0) }.count
            score += matchCount * 3

            // キーワードマッチング（悩みカテゴリ ↔ stone.effects）
            let effectsMatchCount = concernKeywords.filter { stone.effects.contains($0) }.count
            score += effectsMatchCount * 2

            // キーワードマッチング（悩みカテゴリ ↔ stone.concerns）
            let concernsMatchCount = concernKeywords.filter { stone.concerns.contains($0) }.count
            score += concernsMatchCount * 2

            // 誕生月ボーナス
            if stone.birthMonth.contains(birthMonthValue) {
                score += 5
            }

            // 星座ボーナス
            if stone.zodiac.contains(zodiacSign) {
                score += 4
            }

            // ランダム要素（同点の場合に差をつける）
            score += Int.random(in: 0...2)

            return (stone: stone, score: score)
        }

        _ = birthMonth  // suppress unused warning
        scored.sort { $0.score > $1.score }

        let top3 = Array(scored.prefix(3))
        results = top3.enumerated().map { index, item in
            let rank = index + 1
            let score = min(5, max(1, scoreToStars(item.score)))
            let (message, advice) = generateMessage(stone: item.stone, concern: input.concern, rank: rank)
            return FortuneResult(stone: item.stone, score: score, message: message, advice: advice, rank: rank)
        }
        showResult = true
    }

    func reset() {
        results = []
        showResult = false
    }

    // MARK: - Private Helpers

    private func scoreToStars(_ raw: Int) -> Int {
        switch raw {
        case ..<3: return 1
        case 3..<6: return 2
        case 6..<10: return 3
        case 10..<15: return 4
        default: return 5
        }
    }

    private func zodiacFrom(date: Date) -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        switch (month, day) {
        case (3, 21...), (4, ...19): return "牡羊座"
        case (4, 20...), (5, ...20): return "牡牛座"
        case (5, 21...), (6, ...21): return "双子座"
        case (6, 22...), (7, ...22): return "蟹座"
        case (7, 23...), (8, ...22): return "獅子座"
        case (8, 23...), (9, ...22): return "乙女座"
        case (9, 23...), (10, ...23): return "天秤座"
        case (10, 24...), (11, ...22): return "蠍座"
        case (11, 23...), (12, ...21): return "射手座"
        case (12, 22...), (1, ...19): return "山羊座"
        case (1, 20...), (2, ...18): return "水瓶座"
        default: return "魚座"
        }
    }

    private func generateMessage(stone: Stone, concern: ConcernCategory, rank: Int) -> (message: String, advice: String) {
        let name = stone.nameJa
        switch (concern, rank) {
        case (.love, 1):
            return (
                "\(name)があなたの恋愛運を力強く後押しします。真剣な想いが相手に届く時です。",
                "\(name)を左手首に身につけ、好きな人のことを想いながら一日を過ごしてみましょう。"
            )
        case (.love, _):
            return (
                "\(name)の優しいエネルギーが、あなたの魅力をさらに引き出してくれます。",
                "恋愛に迷ったとき、\(name)を握りしめて深呼吸してください。答えが見えてくるでしょう。"
            )
        case (.work, 1):
            return (
                "\(name)があなたの集中力と決断力を高め、仕事での成功へと導きます。",
                "デスクに\(name)を置くと、重要な判断の場面で迷わず行動できるようになります。"
            )
        case (.work, _):
            return (
                "\(name)のエネルギーがプロジェクトの障壁を取り除き、前進する力を与えます。",
                "大事な商談や発表の前に\(name)に触れ、落ち着きと自信をチャージしましょう。"
            )
        case (.health, 1):
            return (
                "\(name)の生命力あふれるエネルギーが、あなたの体と心を内側から整えます。",
                "就寝前に\(name)をお腹の上に置き、深呼吸を10回。回復力が高まります。"
            )
        case (.health, _):
            return (
                "\(name)が身体のエネルギーバランスを整え、活力を引き出してくれます。",
                "運動や散歩のときに\(name)を携帯すると、持久力とやる気が続きやすくなります。"
            )
        case (.money, 1):
            return (
                "\(name)の強力な引き寄せエネルギーが、豊かさと繁栄をあなたのもとに呼び込みます。",
                "財布に\(name)を入れると金運が上昇します。月に一度満月の光で浄化しましょう。"
            )
        case (.money, _):
            return (
                "\(name)が無駄遣いを防ぎ、お金の流れをポジティブに変えてくれます。",
                "支出を見直すタイミングで\(name)を眺めると、本当に必要なものが見えてきます。"
            )
        case (.relationship, 1):
            return (
                "\(name)の調和のエネルギーが、あなたの周囲の人間関係を穏やかに整えます。",
                "誰かと話す前に\(name)を握りしめると、相手を受け入れる余裕が生まれます。"
            )
        case (.relationship, _):
            return (
                "\(name)があなたのコミュニケーション力を高め、信頼関係を築く手助けをします。",
                "職場や学校に\(name)を持参し、困ったときはそっと触れて気持ちを落ち着かせましょう。"
            )
        case (.study, 1):
            return (
                "\(name)の明晰なエネルギーが記憶力と集中力を最大限に高めます。試験前の強い味方です。",
                "勉強机の左上に\(name)を置くと、長時間の集中が続くようになります。"
            )
        case (.study, _):
            return (
                "\(name)の直感力を高めるパワーが、難しい問題のひらめきを助けます。",
                "行き詰まったとき\(name)を手のひらで温めながら目を閉じると、新しいアイデアが浮かびます。"
            )
        case (.family, 1):
            return (
                "\(name)の守護エネルギーが家族全員を包み込み、家庭に平和と安心をもたらします。",
                "リビングの中央や玄関に\(name)を飾ると、家全体の雰囲気が穏やかになります。"
            )
        case (.family, _):
            return (
                "\(name)が家族の絆を深め、日々の暮らしに温かみを加えてくれます。",
                "家族と過ごす時間に\(name)を近くに置くと、会話が弾み関係がより深まります。"
            )
        case (.overall, 1):
            return (
                "\(name)は今のあなたに最も響く石。あらゆる面で運気を押し上げ、全体的な幸運を引き寄せます。",
                "朝起きたら\(name)を両手で包み込み、今日一日の良い流れをイメージしてください。"
            )
        default:
            return (
                "\(name)のバランスの取れたエネルギーが、日常のさまざまな場面であなたをサポートします。",
                "\(name)を日頃から身近に置き、定期的に月光浴や流水で浄化してパワーを保ちましょう。"
            )
        }
    }
}
