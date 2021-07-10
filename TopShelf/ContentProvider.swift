import Combine
import TVServices
import JellyfinAPI
import CoreData

class ContentProvider: TVTopShelfContentProvider {

    func getResumeWatching(completion: @escaping ([BaseItemDto]?) -> Void) {

        guard let _ = ServerEnvironment.current.server,
              let savedUser = SessionManager.current.user,
              let userID = savedUser.user_id else {
            completion(nil)
            return
        }
        print("Fetching continue watching")
        var cancellables = Set<AnyCancellable>()

        ItemsAPI.getResumeItems(userId: userID, limit: 5,
                                fields: [.primaryImageAspectRatio, .seriesPrimaryImage],
                                mediaTypes: ["Video"], imageTypeLimit: 1, enableImageTypes: [.primary, .backdrop, .thumb])
            .subscribe(on: DispatchQueue.global(qos: .background))
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure:
                    completion(nil)
                    break
                }
            }, receiveValue: { response in
                DispatchGroup().notify(queue: .main) {
                    completion(response.items)
                }
            })
            .store(in: &cancellables)

    }

    override func loadTopShelfContent(completionHandler: @escaping (TVTopShelfContent?) -> Void) {
        // Fetch content and call completionHandler
        var contentItems = [TVTopShelfSectionedItem]()

        getResumeWatching { items in

            guard let items = items else {
                completionHandler(nil)
                return
            }
            for item in items {
                let imageUrl = item.type == "Episode" ? item.getSeriesPrimaryImage(maxWidth: 600) : item.getPrimaryImage(maxWidth: 600)
                let name = item.type == "Episode" ? "\(item.getEpisodeLocator()) - \(item.name!) - \(item.seriesName!)" : item.name

                let itemContent = TVTopShelfSectionedItem(identifier: item.id!)
                itemContent.imageShape = .poster
                itemContent.title = name
                itemContent.playbackProgress = (item.userData?.playedPercentage ?? 0) / 100
                itemContent.setImageURL(imageUrl, for: .screenScale2x)

                contentItems.append(itemContent)
            }

            let collection = TVTopShelfItemCollection(items: contentItems)
            collection.title = "Continue Watching"

            let content = TVTopShelfSectionedContent(sections: [collection])

            completionHandler(content)

        }
    }

}
