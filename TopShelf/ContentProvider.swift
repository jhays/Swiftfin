import Combine
import TVServices
import JellyfinAPI


class ContentProvider: TVTopShelfContentProvider {
    
    func getContinueWatching() {
        let server = ServerEnvironment.current.server
        let savedUser = SessionManager.current.user
        var tempCancellables = Set<AnyCancellable>()
    }

    override func loadTopShelfContent(completionHandler: @escaping (TVTopShelfContent?) -> Void) {
        // Fetch content and call completionHandler
        let continueWatching = TVTopShelfSectionedItem(identifier: "ContinueWatchibng")
        continueWatching.imageShape = .poster
        continueWatching.title = "Test"
        
        let collection = TVTopShelfItemCollection(items: [continueWatching])
        let content = TVTopShelfSectionedContent(sections: [collection])
        
        
        
        completionHandler(content)

    }

}

