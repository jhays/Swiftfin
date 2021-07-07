import Foundation
import JellyfinAPI

final class MainTabViewModel: ViewModel {
    @Published var backgroundURL: URL?
    @Published var lastBackgroundURL: URL?
    @Published var backgroundBlurHash: String = "001fC^"

    override init() {
        super.init()

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(backgroundDidChange), name: Notification.Name("backgroundDidChange"), object: nil)
    }

    @objc func backgroundDidChange() {
        self.lastBackgroundURL = self.backgroundURL
        self.backgroundURL = BackgroundManager.current.backgroundURL
        self.backgroundBlurHash = BackgroundManager.current.blurhash
    }
}
