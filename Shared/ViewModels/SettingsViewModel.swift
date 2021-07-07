import Foundation

struct UserSettings: Decodable {
    var LocalMaxBitrate: Int
    var RemoteMaxBitrate: Int
    var AutoSelectSubtitles: Bool
    var AutoSelectSubtitlesLangcode: String
    var SubtitlePositionOffset: Int
    var SubtitleFontName: String
}

struct Bitrates: Codable, Hashable {
    public var name: String
    public var value: Int
}

struct TrackLanguage: Hashable {
    var name: String
    var isoCode: String

    static let auto = TrackLanguage(name: "Auto", isoCode: "Auto")
}

final class SettingsViewModel: ObservableObject {
    let currentLocale = Locale.current
    var bitrates: [Bitrates] = []
    var langs = [TrackLanguage]()

    init() {
        let url = Bundle.main.url(forResource: "bitrates", withExtension: "json")!

        do {
            let jsonData = try Data(contentsOf: url, options: .mappedIfSafe)
            do {
                self.bitrates = try JSONDecoder().decode([Bitrates].self, from: jsonData)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }

        self.langs = Locale.isoLanguageCodes.compactMap {
            guard let name = currentLocale.localizedString(forLanguageCode: $0) else { return nil }
            return TrackLanguage(name: name, isoCode: $0)
        }.sorted(by: { $0.name < $1.name })
        self.langs.insert(.auto, at: 0)
    }
}
