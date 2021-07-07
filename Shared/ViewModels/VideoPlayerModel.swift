import SwiftUI
import JellyfinAPI

struct Subtitle {
    var name: String
    var id: Int32
    var url: URL?
    var delivery: SubtitleDeliveryMethod
    var codec: String
    var languageCode: String
}

struct AudioTrack {
    var name: String
    var languageCode: String
    var id: Int32
}

class PlaybackItem: ObservableObject {
    @Published var videoType: PlayMethod = .directPlay
    @Published var videoUrl: URL = URL(string: "https://example.com")!
}
