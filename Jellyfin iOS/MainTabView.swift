import Foundation
import SwiftUI

struct MainTabView: View {
    @State private var tabSelection: Tab = .home

    var body: some View {
        TabView(selection: $tabSelection) {
            NavigationView {
                HomeView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Text(Tab.home.localized)
                Image(systemName: "house")
            }
            .tag(Tab.home)
            NavigationView {
                LibraryListView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Text(Tab.allMedia.localized)
                Image(systemName: "folder")
            }
            .tag(Tab.allMedia)
        }
    }
}

extension MainTabView {

    enum Tab: String {
        case home
        case allMedia

        var localized: String {
            switch self {
            case .home:
                return "Home"
            case .allMedia:
                return "All Media"
            }
        }
    }
}
