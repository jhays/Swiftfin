//
 /* 
  * SwiftFin is subject to the terms of the Mozilla Public
  * License, v2.0. If a copy of the MPL was not distributed with this
  * file, you can obtain one at https://mozilla.org/MPL/2.0/.
  *
  * Copyright 2021 Aiden Vigue & Jellyfin Contributors
  */

import JellyfinAPI
import SwiftUI

struct ItemViewDetailsView: View {

    @ObservedObject var viewModel: ItemViewModel

    var body: some View {
        VStack(alignment: .leading) {

            if !viewModel.informationItems.isEmpty {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Information")
                        .font(.title3)
                        .fontWeight(.bold)

                    ForEach(viewModel.informationItems, id: \.self.title) { informationItem in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(informationItem.title)
                                .font(.subheadline)
                            Text(informationItem.content)
                                .font(.subheadline)
                                .foregroundColor(Color.secondary)
                        }
                    }
                }
                .padding(.bottom, 20)
            }

            if !viewModel.mediaItems.isEmpty {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Media")
                        .font(.title3)
                        .fontWeight(.bold)

                    ForEach(viewModel.mediaItems, id: \.self.title) { mediaItem in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(mediaItem.title)
                                .font(.subheadline)
                            Text(mediaItem.content)
                                .font(.subheadline)
                                .foregroundColor(Color.secondary)
                        }
                    }
                }
            }
        }
    }
}
