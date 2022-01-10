//
/*
 * SwiftFin is subject to the terms of the Mozilla Public
 * License, v2.0. If a copy of the MPL was not distributed with this
 * file, you can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * Copyright 2021 Aiden Vigue & Jellyfin Contributors
 */

import ActivityIndicator
import Combine
import Foundation
import JellyfinAPI

final class HomeViewModel: ViewModel {

    @Published var librariesShowRecentlyAddedIDs: [String] = []
    @Published var libraries: [BaseItemDto] = []
    @Published var resumeItems: [BaseItemDto] = []
    @Published var nextUpItems: [BaseItemDto] = []

    // temp
    var recentFilterSet: LibraryFilters = LibraryFilters(filters: [], sortOrder: [.descending], sortBy: [.dateAdded])

    override init() {
        super.init()
        refresh()

        // Nov. 6, 2021
        // This is a workaround since Stinsen doesn't have the ability to rebuild a root at the time of writing.
        // See ServerDetailViewModel.swift for feature request issue
        let nc = SwiftfinNotificationCenter.main
        nc.addObserver(self, selector: #selector(didSignIn), name: SwiftfinNotificationCenter.Keys.didSignIn, object: nil)
        nc.addObserver(self, selector: #selector(didSignOut), name: SwiftfinNotificationCenter.Keys.didSignOut, object: nil)
    }

    @objc private func didSignIn() {
        for cancellable in cancellables {
            cancellable.cancel()
        }

        librariesShowRecentlyAddedIDs = []
        libraries = []
        resumeItems = []
        nextUpItems = []

        refresh()
    }

    @objc private func didSignOut() {
        for cancellable in cancellables {
            cancellable.cancel()
        }

        cancellables.removeAll()
    }

    @objc func refresh() {
        LogManager.shared.log.debug("Refresh called.")

        refreshLibrariesLatest()
        refreshResumeItems()
        refreshNextUpItems()
    }

    // MARK: Libraries Latest Items
    private func refreshLibrariesLatest() {
        UserViewsAPI.getUserViews(userId: SessionManager.main.currentLogin.user.id)
            .trackActivity(loading)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: ()
                case .failure:
                    self.libraries = []
                }

                self.handleAPIRequestError(completion: completion)
            }, receiveValue: { response in

                var newLibraries: [BaseItemDto] = []

                response.items!.forEach { item in
                    LogManager.shared.log.debug("Retrieved user view: \(item.id!) (\(item.name ?? "nil")) with type \(item.collectionType ?? "nil")")
                    if item.collectionType == "movies" || item.collectionType == "tvshows" {
                        newLibraries.append(item)
                    }
                }

                UserAPI.getCurrentUser()
                    .trackActivity(self.loading)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished: ()
                        case .failure:
                            self.libraries = []
                            self.handleAPIRequestError(completion: completion)
                        }
                    }, receiveValue: { response in
                        let excludeIDs = response.configuration?.latestItemsExcludes != nil ? response.configuration!.latestItemsExcludes! : []

                        for excludeID in excludeIDs {
                            newLibraries.removeAll { library in
                                return library.id == excludeID
                            }
                        }

                        self.libraries = newLibraries
                    })
                    .store(in: &self.cancellables)
            })
            .store(in: &cancellables)
    }

    // MARK: Resume Items
    private func refreshResumeItems() {
        ItemsAPI.getResumeItems(userId: SessionManager.main.currentLogin.user.id, limit: 12,
                                fields: [.primaryImageAspectRatio, .seriesPrimaryImage, .seasonUserData, .overview, .genres, .people, .chapters],
                                mediaTypes: ["Video"],
                                imageTypeLimit: 1,
                                enableImageTypes: [.primary, .backdrop, .thumb])
            .trackActivity(loading)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: ()
                case .failure:
                    self.resumeItems = []
                    self.handleAPIRequestError(completion: completion)
                }
            }, receiveValue: { response in
                LogManager.shared.log.debug("Retrieved \(String(response.items!.count)) resume items")

                self.resumeItems = response.items ?? []
            })
            .store(in: &cancellables)
    }

    // MARK: Next Up Items
    private func refreshNextUpItems() {
        TvShowsAPI.getNextUp(userId: SessionManager.main.currentLogin.user.id, limit: 12,
                             fields: [.primaryImageAspectRatio, .seriesPrimaryImage, .seasonUserData, .overview, .genres, .people, .chapters])
            .trackActivity(loading)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: ()
                case .failure:
                    self.nextUpItems = []
                    self.handleAPIRequestError(completion: completion)
                }
            }, receiveValue: { response in
                LogManager.shared.log.debug("Retrieved \(String(response.items!.count)) nextup items")

                self.nextUpItems = response.items ?? []
            })
            .store(in: &cancellables)
    }
}
