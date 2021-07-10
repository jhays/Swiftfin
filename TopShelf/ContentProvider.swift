import Combine
import TVServices
import JellyfinAPI

class ContentProvider: TVTopShelfContentProvider {

    
    func getResumeWatching(completion: @escaping ([BaseItemDto]?) -> ()) {
        
        let server = ServerEnvironment.current.server
        let savedUser = SessionManager.current.user
        var cancellables = Set<AnyCancellable>()
        var resumeItems = [BaseItemDto]()
        if let userID = savedUser?.user_id {
            ItemsAPI.getResumeItems(userId: userID, limit: 5,
                                    fields: [.primaryImageAspectRatio, .seriesPrimaryImage, .seasonUserData, .overview, .genres, .people],
                                    mediaTypes: ["Video"], imageTypeLimit: 1, enableImageTypes: [.primary, .backdrop, .thumb])
                .sink(receiveCompletion: { completion in
                }, receiveValue: { response in
                    completion(response.items)
                })
                .store(in: &cancellables)
        }
        
    }
 
    override func loadTopShelfContent(completionHandler: @escaping (TVTopShelfContent?) -> Void) {
        // Fetch content and call completionHandler
        var contentItems = [TVTopShelfSectionedItem]()
        
        getResumeWatching { items in
            if let items = items {
                print("Has item")
                print(items)
                for item in items {
                    let itemContent = TVTopShelfSectionedItem(identifier: item.id!)
                    itemContent.imageShape = .poster
                    itemContent.title = item.name
                    itemContent.setImageURL(item.getPrimaryImage(maxWidth: 200), for: .screenScale1x)
                    contentItems.append(itemContent)
                }
            }
            else{
                completionHandler(nil)
            }
            
        }

        let collection = TVTopShelfItemCollection(items: contentItems)
        collection.title = "Continue Watching"
        let content = TVTopShelfSectionedContent(sections: [collection])
        
        completionHandler(content)
      

    }

}
