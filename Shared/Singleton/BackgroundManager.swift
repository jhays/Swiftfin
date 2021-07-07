import Foundation

final class BackgroundManager {
    static let current = BackgroundManager()
    fileprivate(set) var backgroundURL: URL?
    fileprivate(set) var blurhash: String = "001fC^"

    init() {
        backgroundURL = nil
    }

    func setBackground(to: URL, hash: String) {
        self.backgroundURL = to
        self.blurhash = hash

        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("backgroundDidChange"), object: nil)
    }

    func clearBackground() {
        self.backgroundURL = nil
        self.blurhash = "001fC^"

        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("backgroundDidChange"), object: nil)
    }
}
