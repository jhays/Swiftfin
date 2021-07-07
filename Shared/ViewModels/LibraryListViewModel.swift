import Foundation
import JellyfinAPI

final class LibraryListViewModel: ViewModel {
    @Published
    var libraries = [BaseItemDto]()

    // temp
    var withFavorites = LibraryFilters(filters: [.isFavorite], sortOrder: [], withGenres: [], sortBy: [])

    override init() {
        super.init()

        requestLibraries()
    }

    func requestLibraries() {
        UserViewsAPI.getUserViews(userId: SessionManager.current.user.user_id!)
            .trackActivity(loading)
            .sink(receiveCompletion: { completion in
                self.handleAPIRequestCompletion(completion: completion)
            }, receiveValue: { response in
                self.libraries.append(contentsOf: response.items ?? [])
            })
            .store(in: &cancellables)
    }
}
