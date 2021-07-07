import Foundation
import Defaults

extension Defaults.Keys {
    static let inNetworkBandwidth = Key<Int>("InNetworkBandwidth", default: 40_000_000)
    static let outOfNetworkBandwidth = Key<Int>("OutOfNetworkBandwidth", default: 40_000_000)
    static let isAutoSelectSubtitles = Key<Bool>("isAutoSelectSubtitles", default: false)
    static let autoSelectSubtitlesLangCode = Key<String>("AutoSelectSubtitlesLangCode", default: "Auto")
    static let autoSelectAudioLangCode = Key<String>("AutoSelectAudioLangCode", default: "Auto")
}
