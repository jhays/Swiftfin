//
 /* 
  * SwiftFin is subject to the terms of the Mozilla Public
  * License, v2.0. If a copy of the MPL was not distributed with this
  * file, you can obtain one at https://mozilla.org/MPL/2.0/.
  *
  * Copyright 2021 Aiden Vigue & Jellyfin Contributors
  */

import SwiftUI

struct MediaPlayButtonRowView: View {
    @EnvironmentObject var itemRouter: ItemCoordinator.Router
    @ObservedObject var viewModel: ItemViewModel
    @State var wrappedScrollView: UIScrollView?

    var body: some View {
        HStack {
            VStack {
                Button {
                    self.itemRouter.route(to: \.videoPlayer, viewModel.item)
                } label: {
                    MediaViewActionButton(icon: "play.fill", scrollView: $wrappedScrollView)
                }
                Text(viewModel.item.getItemProgressString() != "" ? "\(viewModel.item.getItemProgressString()) left" : "Play")
                    .font(.caption)
            }
            VStack {
                Button {
                    viewModel.updateWatchState()
                } label: {
                    MediaViewActionButton(icon: "eye.fill", scrollView: $wrappedScrollView, iconColor: viewModel.isWatched ? .red : .white)
                }
                Text(viewModel.isWatched ? "Unwatch" : "Mark Watched")
                    .font(.caption)
            }
            VStack {
                Button {
                    viewModel.updateFavoriteState()
                } label: {
                    MediaViewActionButton(icon: "heart.fill", scrollView: $wrappedScrollView, iconColor: viewModel.isFavorited ? .red : .white)
                }
                Text(viewModel.isFavorited ? "Unfavorite" : "Favorite")
                    .font(.caption)
            }
            Spacer()
        }
    }
}
