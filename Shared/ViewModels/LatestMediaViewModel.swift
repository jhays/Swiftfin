import Combine
import Foundation
import JellyfinAPI

final class LatestMediaViewModel: ViewModel {
    @Published
    var items = [BaseItemDto]()

    var libraryID: String

    init(libraryID: String) {
        self.libraryID = libraryID
        super.init()

        requestLatestMedia()
    }

    func requestLatestMedia() {
        UserLibraryAPI.getLatestMedia(userId: SessionManager.current.user.user_id!, parentId: libraryID,
                                      fields: [
                                          .primaryImageAspectRatio,
                                          .seriesPrimaryImage,
                                          .seasonUserData,
                                          .overview,
                                          .genres,
                                          .people
                                      ],
                                      enableUserData: true, limit: 12)
            .trackActivity(loading)
            .sink(receiveCompletion: { [weak self] completion in
                self?.handleAPIRequestCompletion(completion: completion)
            }, receiveValue: { [weak self] response in
                self?.items = response
            })
            .store(in: &cancellables)
    }
}
