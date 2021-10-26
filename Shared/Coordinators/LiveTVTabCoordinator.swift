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

final class LiveTVTabCoordinator: TabCoordinatable {
    var child = TabChild(startingItems: [
        \LiveTVTabCoordinator.programs,
        \LiveTVTabCoordinator.guide
    ])
    
    @Route(tabItem: makeProgramsTab) var programs = makePrograms
    @Route(tabItem: makeGuideTab) var guide = makeGuide
    
    func makePrograms() -> NavigationViewCoordinator<LiveTVProgramsCoordinator> {
        return NavigationViewCoordinator(LiveTVProgramsCoordinator())
    }
    
    @ViewBuilder func makeProgramsTab(isActive: Bool) -> some View {
        HStack {
            Image(systemName: "tv")
            Text("Programs")
        }
    }
    
    func makeGuide() -> NavigationViewCoordinator<LiveTVGuideCoordinator> {
        return NavigationViewCoordinator(LiveTVGuideCoordinator())
    }
    
    @ViewBuilder func makeGuideTab(isActive: Bool) -> some View {
        HStack {
            Image(systemName: "calendar")
            Text("Guide")
        }
    }
}
