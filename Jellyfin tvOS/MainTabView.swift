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
                
                Text("Movies")
                    .tabItem {
                        Text(Tab.movies.localized)
                    }
                    .tag(Tab.movies)
                
                Text("TV Shows")
                    .tabItem {
                        Text(Tab.tv_shows.localized)
                    }
                    .tag(Tab.tv_shows)
                
                Text("Search")
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                    }
                    .tag(Tab.search)
                
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
        case movies
        case tv_shows
        case search
        
        var localized: String {
            switch self {
            case .home:
                return "Home"
            case .movies:
                return "Movies"
            case .tv_shows:
                return "TV Shows"
            case .search:
                return "Search"
            }
        }
    }
}

// stream ancient dreams in a modern land by MARINA!
