import Combine
import Foundation
import JellyfinAPI

final class SeriesItemViewModel: DetailItemViewModel {
    @Published var seasons = [BaseItemDto]()
    @Published var nextUpItem: BaseItemDto?
    
    override init(item: BaseItemDto) {
        super.init(item: item)
        self.item = item
        
        requestSeasons()
        getNextUp()
    }
    
    func getNextUp() {
        TvShowsAPI.getNextUp(userId: SessionManager.current.user.user_id!, fields: [.primaryImageAspectRatio, .seriesPrimaryImage, .seasonUserData, .overview, .genres, .people], seriesId: self.item.id!, enableUserData: true)
            .trackActivity(loading)
            .sink(receiveCompletion: { [weak self] completion in
                self?.handleAPIRequestCompletion(completion: completion)
            }, receiveValue: { [weak self] response in
                self?.nextUpItem = response.items?.first ?? nil
            })
            .store(in: &cancellables)
    }
    
    func getRunYears() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        
        var startYear: String? = nil
        var endYear: String? = nil
        
        if(item.premiereDate != nil) {
            startYear = dateFormatter.string(from: item.premiereDate!)
        }
        
        if(item.endDate != nil) {
            endYear = dateFormatter.string(from: item.endDate!)
        }
        
        return "\(startYear ?? "Unknown") - \(endYear ?? "Present")"
    }

    func requestSeasons() {
        TvShowsAPI.getSeasons(seriesId: item.id ?? "", userId: SessionManager.current.user.user_id!, fields: [.primaryImageAspectRatio, .seriesPrimaryImage, .seasonUserData, .overview, .genres, .people], enableUserData: true)
            .trackActivity(loading)
            .sink(receiveCompletion: { [weak self] completion in
                self?.handleAPIRequestCompletion(completion: completion)
            }, receiveValue: { [weak self] response in
                self?.seasons = response.items ?? []
            })
            .store(in: &cancellables)
    }
}
