import Combine
import Foundation
import JellyfinAPI

final class SeasonItemViewModel: DetailItemViewModel {
    @Published var episodes = [BaseItemDto]()
    
    override init(item: BaseItemDto) {
        super.init(item: item)
        self.item = item
        
        requestEpisodes()
    }

    func requestEpisodes() {
        TvShowsAPI.getEpisodes(seriesId: item.seriesId ?? "", userId: SessionManager.current.user.user_id!,
                               fields: [.primaryImageAspectRatio, .seriesPrimaryImage, .seasonUserData, .overview, .genres, .people],
                               seasonId: item.id ?? "")
            .trackActivity(loading)
            .sink(receiveCompletion: { [weak self] completion in
                self?.handleAPIRequestCompletion(completion: completion)
            }, receiveValue: { [weak self] response in
                self?.episodes = response.items ?? []
            })
            .store(in: &cancellables)
    }
}
