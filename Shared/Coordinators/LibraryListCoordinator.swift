//
/*
 * SwiftFin is subject to the terms of the Mozilla Public
 * License, v2.0. If a copy of the MPL was not distributed with this
 * file, you can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * Copyright 2021 Aiden Vigue & Jellyfin Contributors
 */

import Foundation
import Stinsen
import SwiftUI

final class LibraryListCoordinator: NavigationCoordinatable {
    
    let stack = NavigationStack(initial: \LibraryListCoordinator.start)

    @Root var start = makeStart
    @Route(.push) var search = makeSearch
    @Route(.push) var library = makeLibrary
    @Route(.modal) var liveTvTabs = makeLiveTvTabs
    
    let viewModel: LibraryListViewModel

    init(viewModel: LibraryListViewModel) {
        self.viewModel = viewModel
    }
    
    func makeLibrary(params: LibraryCoordinatorParams) -> LibraryCoordinator {
        LibraryCoordinator(viewModel: params.viewModel, title: params.title)
    }

    func makeSearch(viewModel: LibrarySearchViewModel) -> SearchCoordinator {
        SearchCoordinator(viewModel: viewModel)
    }
    
    func makeLiveTvTabs() -> LiveTVTabCoordinator {
        LiveTVTabCoordinator()
    }

    @ViewBuilder
    func makeStart() -> some View {
        LibraryListView(viewModel: self.viewModel)
    }
}
