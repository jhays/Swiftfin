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
          \LiveTVTabCoordinator.channels,
          \LiveTVTabCoordinator.home
    ])

    @Route(tabItem: makeProgramsTab) var programs = makePrograms
    @Route(tabItem: makeChannelsTab) var channels = makeChannels
    @Route(tabItem: makeHomeTab) var home = makeHome

    func makePrograms() -> NavigationViewCoordinator<LiveTVProgramsCoordinator> {
        return NavigationViewCoordinator(LiveTVProgramsCoordinator())
    }

    @ViewBuilder func makeProgramsTab(isActive: Bool) -> some View {
        HStack {
            Image(systemName: "tv")
            Text("Programs")
        }
    }

    func makeChannels() -> NavigationViewCoordinator<LiveTVChannelsCoordinator> {
        return NavigationViewCoordinator(LiveTVChannelsCoordinator())
    }

    @ViewBuilder func makeChannelsTab(isActive: Bool) -> some View {
        HStack {
            Image(systemName: "square.grid.3x3")
            Text("Channels")
        }
    }

    func makeHome() -> LiveTVHomeView {
        return LiveTVHomeView()
    }

    @ViewBuilder func makeHomeTab(isActive: Bool) -> some View {
        HStack {
            Image(systemName: "house")
            Text("Home")
        }
    }
}
