import Foundation

enum Constants {
    enum Amazon {
        static let affiliateID = "kixyouhueizou-22"
        static let baseURL = "https://www.amazon.co.jp/s"

        static func searchURL(query: String) -> URL? {
            var components = URLComponents(string: baseURL)
            components?.queryItems = [
                URLQueryItem(name: "k", value: query),
                URLQueryItem(name: "tag", value: affiliateID)
            ]
            return components?.url
        }
    }

    enum Colors {
        static let backgroundTop = "#2D1B69"
        static let backgroundBottom = "#0F1B3D"
        static let accent = "#D4AF37"
        static let cardBackground = "ultraThinMaterial"
    }

    enum UserDefaultsKeys {
        static let lastDailyFortuneDate = "lastDailyFortuneDate"
        static let lastDailyFortuneStoneID = "lastDailyFortuneStoneID"
        static let lastDailyFortuneLuck = "lastDailyFortuneLuck"
        static let lastDailyFortuneLuckyColor = "lastDailyFortuneLuckyColor"
        static let lastDailyFortuneLuckyNumber = "lastDailyFortuneLuckyNumber"
    }

}
