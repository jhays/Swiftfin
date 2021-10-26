//
/*
 * SwiftFin is subject to the terms of the Mozilla Public
 * License, v2.0. If a copy of the MPL was not distributed with this
 * file, you can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * Copyright 2021 Aiden Vigue & Jellyfin Contributors
 */

import Foundation
import SwiftUI
import Stinsen

final class MainTabCoordinator: TabCoordinatable {
    var child = TabChild(startingItems: [
        \MainTabCoordinator.home,
        \MainTabCoordinator.allMedia
    ])

    @Route(tabItem: makeHomeTab) var home = makeHome
    @Route(tabItem: makeAllMediaTab) var allMedia = makeAllMedia

    func makeHome() -> NavigationViewCoordinator<HomeCoordinator> {
        return NavigationViewCoordinator(HomeCoordinator())
    }

    @ViewBuilder func makeHomeTab(isActive: Bool) -> some View {
        Image(systemName: "house")
        Text("Home")
    }

    func makeAllMedia() -> NavigationViewCoordinator<LibraryListCoordinator> {
        return NavigationViewCoordinator(LibraryListCoordinator(viewModel: LibraryListViewModel()))
    }

    @ViewBuilder func makeAllMediaTab(isActive: Bool) -> some View {
        Image(systemName: "folder")
        Text("All Media")
    }

    @ViewBuilder func customize(_ view: AnyView) -> some View {
        view.onAppear {
            AppURLHandler.shared.appURLState = .allowed
            // TODO: todo
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {                
                AppURLHandler.shared.processLaunchedURLIfNeeded()
            }
        }
    }
}
