import Foundation
import SwiftUI
import JellyfinAPI

struct MainTabView: View {
    @State private var tabSelection: Tab = .home
    @StateObject private var viewModel = MainTabViewModel()
    @State private var backdropAnim: Bool = true
    @State private var lastBackdropAnim: Bool = false
    
    @State var itemToShow: BaseItemDto = BaseItemDto()
    @State var showItemView: Bool = false
    @State var loading: Bool = true
    
    var body: some View {
        ZStack {
            if loading {
                ProgressView()
            }
            
            TabView(selection: $tabSelection) {
                HomeView(itemToShow: $itemToShow, showItemView: $showItemView, loading: $loading)
                    .ignoresSafeArea()
                    .offset(y: -1) // don't remove this. it breaks tabview on 4K displays.
                    .tabItem {
                        Text(Tab.home.localized)
                    }
                    .tag(Tab.home)
                
                Text("Library")
                    .tabItem {
                        Text(Tab.allMedia.localized)
                    }
                    .tag(Tab.allMedia)
            }
            .background(
                NavigationLink(
                    destination: ItemView(item: itemToShow),
                    isActive: $showItemView,
                    label: {
                        EmptyView()
                    })
                    .opacity(0)
            )
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

// stream ancient dreams in a modern land by MARINA!
