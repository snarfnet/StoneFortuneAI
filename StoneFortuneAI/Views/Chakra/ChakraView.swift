import SwiftUI

// MARK: - Chakra Data

private struct ChakraInfo: Identifiable {
    let id: Int
    let number: String
    let nameJa: String
    let nameEn: String
    let sanskrit: String
    let color: String
    let emoji: String
    let location: String
    let locationEn: String
    let element: String
    let keyword: String
    let keywordEn: String
    let description: String
    let descriptionEn: String
    let stoneChakraLabel: String
}

private let chakras: [ChakraInfo] = [
    ChakraInfo(id: 1, number: "第1",
               nameJa: "ルート・チャクラ", nameEn: "Root Chakra",
               sanskrit: "Muladhara",
               color: "#C0392B", emoji: "🔴",
               location: "尾骨・骨盤底", locationEn: "Coccyx / Base of Spine",
               element: "土", keyword: "安定・大地", keywordEn: "Grounding · Security",
               description: "生命力と安全感の源。大地とのつながりを司り、肉体的な安定と基盤を作る。バランスが取れると安心感と忍耐力が高まる。",
               descriptionEn: "The foundation of life force and security. Governs your connection to the earth and physical stability.",
               stoneChakraLabel: "第1チャクラ"),
    ChakraInfo(id: 2, number: "第2",
               nameJa: "サクラル・チャクラ", nameEn: "Sacral Chakra",
               sanskrit: "Svadhisthana",
               color: "#E67E22", emoji: "🟠",
               location: "下腹部・仙骨", locationEn: "Lower Abdomen / Sacrum",
               element: "水", keyword: "創造・感情", keywordEn: "Creativity · Emotion",
               description: "感情と創造性を司る。喜び、快楽、性エネルギーの中枢。活性化すると創造力が溢れ、感情が豊かになる。",
               descriptionEn: "Governs emotions, creativity, and sensual energy. Activation brings joy and creative flow.",
               stoneChakraLabel: "第2チャクラ"),
    ChakraInfo(id: 3, number: "第3",
               nameJa: "ソーラープレクサス", nameEn: "Solar Plexus Chakra",
               sanskrit: "Manipura",
               color: "#F1C40F", emoji: "🟡",
               location: "みぞおち・腹部", locationEn: "Upper Abdomen / Solar Plexus",
               element: "火", keyword: "意志・自信", keywordEn: "Willpower · Confidence",
               description: "自己意志と自信の源。個人のパワーと決断力を司る。バランスが取れると自己肯定感と行動力が高まる。",
               descriptionEn: "The seat of personal power and willpower. Balanced chakra brings confidence and decisive action.",
               stoneChakraLabel: "第3チャクラ"),
    ChakraInfo(id: 4, number: "第4",
               nameJa: "ハート・チャクラ", nameEn: "Heart Chakra",
               sanskrit: "Anahata",
               color: "#27AE60", emoji: "💚",
               location: "胸部・心臓", locationEn: "Center of Chest / Heart",
               element: "風", keyword: "愛・慈悲", keywordEn: "Love · Compassion",
               description: "無条件の愛と慈悲の中心。人との深いつながりと自己愛を育む。開かれると愛情が溢れ、他者への共感が深まる。",
               descriptionEn: "The center of unconditional love and compassion. Opening this chakra deepens connection and self-love.",
               stoneChakraLabel: "第4チャクラ"),
    ChakraInfo(id: 5, number: "第5",
               nameJa: "スロート・チャクラ", nameEn: "Throat Chakra",
               sanskrit: "Vishuddha",
               color: "#2980B9", emoji: "🔵",
               location: "喉・首", locationEn: "Throat / Neck",
               element: "空", keyword: "表現・真実", keywordEn: "Expression · Truth",
               description: "コミュニケーションと自己表現を司る。真実を語る力と、自分の声を世界に届ける勇気を与える。",
               descriptionEn: "Governs communication, self-expression, and speaking your truth with clarity and courage.",
               stoneChakraLabel: "第5チャクラ"),
    ChakraInfo(id: 6, number: "第6",
               nameJa: "サードアイ・チャクラ", nameEn: "Third Eye Chakra",
               sanskrit: "Ajna",
               color: "#8E44AD", emoji: "🟣",
               location: "眉間", locationEn: "Between the Eyebrows",
               element: "光", keyword: "直感・洞察", keywordEn: "Intuition · Insight",
               description: "直感力と内なる知恵の座。見えないものを感じ取る力を育む。活性化すると洞察力が鋭くなり霊的知覚が高まる。",
               descriptionEn: "The seat of intuition and inner wisdom. Activation heightens perception, insight, and psychic awareness.",
               stoneChakraLabel: "第6チャクラ"),
    ChakraInfo(id: 7, number: "第7",
               nameJa: "クラウン・チャクラ", nameEn: "Crown Chakra",
               sanskrit: "Sahasrara",
               color: "#9B59B6", emoji: "⚪",
               location: "頭頂", locationEn: "Top of the Head",
               element: "宇宙", keyword: "悟り・宇宙意識", keywordEn: "Enlightenment · Unity",
               description: "宇宙意識とのつながりを司る最高位のチャクラ。全てとの一体感と、深い精神的悟りへの扉を開く。",
               descriptionEn: "The highest chakra, connecting you to universal consciousness, spiritual enlightenment, and divine unity.",
               stoneChakraLabel: "第7チャクラ"),
]

// MARK: - Main View

struct ChakraView: View {
    @State private var selectedChakra: ChakraInfo? = nil
    @StateObject private var stoneBook = StoneBookViewModel()

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {

                    // Header
                    VStack(spacing: 6) {
                        Text("✨")
                            .font(.system(size: 52))
                        Text("チャクラ診断")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        Text("Chakra Stone Guide")
                            .font(.subheadline).italic()
                            .foregroundColor(.white.opacity(0.5))
                        Text("チャクラに対応する天然石を探す")
                            .font(.caption)
                            .foregroundColor(Color(hex: Constants.Colors.accent).opacity(0.8))
                    }
                    .padding(.top, 24)

                    // Chakra selector
                    VStack(spacing: 10) {
                        ForEach(chakras) { chakra in
                            ChakraRow(chakra: chakra,
                                      isSelected: selectedChakra?.id == chakra.id) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedChakra = (selectedChakra?.id == chakra.id) ? nil : chakra
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    // Detail + matching stones
                    if let chakra = selectedChakra {
                        ChakraDetailCard(chakra: chakra,
                                         stones: stoneBook.stones.filter { $0.chakra == chakra.stoneChakraLabel })
                        .padding(.horizontal, 16)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    Spacer(minLength: 40)
                }
            }
        }
    }
}

// MARK: - Chakra Row

private struct ChakraRow: View {
    let chakra: ChakraInfo
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Color circle
                ZStack {
                    Circle()
                        .fill(Color(hex: chakra.color).opacity(0.25))
                        .frame(width: 50, height: 50)
                    Circle()
                        .strokeBorder(Color(hex: chakra.color), lineWidth: 2)
                        .frame(width: 50, height: 50)
                    Text(chakra.emoji)
                        .font(.system(size: 22))
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(chakra.number)
                            .font(.caption.bold())
                            .foregroundColor(Color(hex: chakra.color))
                        Text(chakra.nameJa)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                    }
                    Text(chakra.nameEn + " · " + chakra.sanskrit)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                    Text(chakra.keyword)
                        .font(.caption)
                        .foregroundColor(Color(hex: chakra.color).opacity(0.9))
                }

                Spacer()

                Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(14)
            .background(
                isSelected
                    ? Color(hex: chakra.color).opacity(0.15)
                    : Color.white.opacity(0.06)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        isSelected ? Color(hex: chakra.color).opacity(0.6) : Color.white.opacity(0.12),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .cornerRadius(14)
        }
    }
}

// MARK: - Chakra Detail Card

private struct ChakraDetailCard: View {
    let chakra: ChakraInfo
    let stones: [Stone]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Title row
            HStack {
                Text(chakra.emoji).font(.title)
                VStack(alignment: .leading, spacing: 2) {
                    Text(chakra.nameJa)
                        .font(.headline.bold())
                        .foregroundColor(Color(hex: chakra.color))
                    Text(chakra.nameEn + " · " + chakra.sanskrit)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer()
                Text(chakra.location)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.trailing)
            }

            Divider().background(Color(hex: chakra.color).opacity(0.4))

            // Description
            Text(chakra.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(4)

            Text(chakra.descriptionEn)
                .font(.caption)
                .foregroundColor(.white.opacity(0.45))
                .lineSpacing(3)
                .italic()

            // Info chips
            HStack(spacing: 10) {
                InfoChip(label: "元素", value: chakra.element, color: chakra.color)
                InfoChip(label: "Keywords", value: chakra.keywordEn, color: chakra.color)
                InfoChip(label: "Location", value: chakra.locationEn.components(separatedBy: " / ").first ?? chakra.locationEn, color: chakra.color)
            }

            Divider().background(Color(hex: chakra.color).opacity(0.4))

            // Matching stones
            if stones.isEmpty {
                Text("対応ストーンは図鑑で検索してください")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            } else {
                Text("対応する天然石 · Corresponding Stones")
                    .font(.caption.bold())
                    .foregroundColor(Color(hex: chakra.color))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(stones) { stone in
                            ChakraStoneCard(stone: stone, accentColor: chakra.color)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color(hex: chakra.color).opacity(0.4), lineWidth: 1.5)
        )
        .cornerRadius(18)
    }
}

private struct InfoChip: View {
    let label: String
    let value: String
    let color: String

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.5))
            Text(value)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(hex: color))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(hex: color).opacity(0.1))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color(hex: color).opacity(0.3), lineWidth: 1))
        .cornerRadius(8)
    }
}

private struct ChakraStoneCard: View {
    let stone: Stone
    let accentColor: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(hex: stone.color).opacity(0.25))
                    .frame(width: 52, height: 52)
                Circle()
                    .strokeBorder(Color(hex: stone.color), lineWidth: 1.5)
                    .frame(width: 52, height: 52)
                Text(stone.emoji)
                    .font(.system(size: 24))
            }
            Text(stone.nameJa)
                .font(.caption.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            Text(stone.nameEn)
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.5))
                .lineLimit(1)
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .padding(.horizontal, 6)
        .background(Color.white.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color(hex: accentColor).opacity(0.25), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}
