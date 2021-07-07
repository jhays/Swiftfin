import SwiftUI
import UIKit
@main
struct JellyfinPlayer_tvOSApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .ignoresSafeArea(.all, edges: .all)
        }
    }
}
