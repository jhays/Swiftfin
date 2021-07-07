import Foundation
import Combine
import Nuke

#if !os(tvOS)
import WidgetKit
#endif

final class SplashViewModel: ViewModel {

    @Published var isLoggedIn: Bool = false

    override init() {
        isLoggedIn = ServerEnvironment.current.server != nil && SessionManager.current.user != nil
        super.init()

        ImageCache.shared.costLimit = 125 * 1024 * 1024 // 125MB memory
        DataLoader.sharedUrlCache.diskCapacity = 1000 * 1024 * 1024 // 1000MB disk

        #if !os(tvOS)
        WidgetCenter.shared.reloadAllTimelines()
        #endif

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(didLogIn), name: Notification.Name("didSignIn"), object: nil)
        nc.addObserver(self, selector: #selector(didLogOut), name: Notification.Name("didSignOut"), object: nil)
    }

    @objc func didLogIn() {
        print("didLogIn")
        isLoggedIn = true
    }

    @objc func didLogOut() {
        print("didLogOut")
        isLoggedIn = false
    }
}
