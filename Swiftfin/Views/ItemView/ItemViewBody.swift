//
/*
 * SwiftFin is subject to the terms of the Mozilla Public
 * License, v2.0. If a copy of the MPL was not distributed with this
 * file, you can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * Copyright 2021 Aiden Vigue & Jellyfin Contributors
 */

import Defaults
import JellyfinAPI
import SwiftUI

struct ItemViewBody: View {

    @EnvironmentObject var itemRouter: ItemCoordinator.Router
    @EnvironmentObject private var viewModel: ItemViewModel
    @Default(.showCastAndCrew) var showCastAndCrew

    var body: some View {
        VStack(alignment: .leading) {
            // MARK: Overview

            Text(viewModel.item.overview ?? "")
                .font(.footnote)
                .padding(.horizontal, 16)
                .padding(.vertical, 3)

            // MARK: Seasons

            if let seriesViewModel = viewModel as? SeriesItemViewModel {
                PortraitImageHStackView(items: seriesViewModel.seasons,
                                        topBarView: {
                    L10n.seasons.text
                                                .fontWeight(.semibold)
                                                .padding(.bottom)
                                                .padding(.horizontal)
                                        }, selectedAction: { season in
                                            itemRouter.route(to: \.item, season)
                                        })
            }

            // MARK: Genres

            PillHStackView(title: L10n.genres,
                           items: viewModel.item.genreItems ?? [],
                           selectedAction: { genre in
                               itemRouter.route(to: \.library, (viewModel: .init(genre: genre), title: genre.title))
                           })
                .padding(.bottom)

            // MARK: Studios

            if let studios = viewModel.item.studios {
                PillHStackView(title: L10n.studios,
                               items: studios) { studio in
                    itemRouter.route(to: \.library, (viewModel: .init(studio: studio), title: studio.name ?? ""))
                }
                               .padding(.bottom)
            }

            // MARK: Episodes

            if let episodeViewModel = viewModel as? EpisodeItemViewModel {
                EpisodesRowView(viewModel: EpisodesRowViewModel(episodeItemViewModel: episodeViewModel))
            }

            // MARK: Series

            if let episodeViewModel = viewModel as? EpisodeItemViewModel {
                if let seriesItem = episodeViewModel.series {
                    let a = [seriesItem]
                    PortraitImageHStackView(items: a) {
                        Text("Series")
                            .fontWeight(.semibold)
                            .padding(.bottom)
                            .padding(.horizontal)
                    } selectedAction: { seriesItem in
                        itemRouter.route(to: \.item, seriesItem)
                    }
                }
            }

            // MARK: Collection Items

            if let collectionViewModel = viewModel as? CollectionItemViewModel {
                PortraitImageHStackView(items: collectionViewModel.collectionItems) {
                    Text("Items")
                        .fontWeight(.semibold)
                        .padding(.bottom)
                        .padding(.horizontal)
                } selectedAction: { collectionItem in
                    itemRouter.route(to: \.item, collectionItem)
                }
            }

            // MARK: Cast & Crew

            if showCastAndCrew {
                if let castAndCrew = viewModel.item.people {
                    PortraitImageHStackView(items: castAndCrew.filter { BaseItemPerson.DisplayedType.allCasesRaw.contains($0.type ?? "") },
                                            topBarView: {
                                                Text("Cast & Crew")
                                                    .fontWeight(.semibold)
                                                    .padding(.bottom)
                                                    .padding(.horizontal)
                                            },
                                            selectedAction: { person in
                                                itemRouter.route(to: \.library, (viewModel: .init(person: person), title: person.title))
                                            })
                }
            }

            // MARK: More Like This

            if !viewModel.similarItems.isEmpty {
                PortraitImageHStackView(items: viewModel.similarItems,
                                        topBarView: {
                    L10n.moreLikeThis.text
                                                .fontWeight(.semibold)
                                                .padding(.bottom)
                                                .padding(.horizontal)
                                        },
                                        selectedAction: { item in
                                            itemRouter.route(to: \.item, item)
                                        })
            }

            // MARK: Details

            switch viewModel.item.itemType {
            case .movie, .episode:
                ItemViewDetailsView(viewModel: viewModel)
                    .padding()
            default:
                EmptyView()
                    .frame(height: 50)
            }
        }
    }
}
