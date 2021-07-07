import SwiftUI
import JellyfinAPI
import Combine

struct LatestMediaView: View {

    @StateObject var tempViewModel = ViewModel()
    @State var items: [BaseItemDto] = []
    private var library_id: String = ""
    @State private var viewDidLoad: Bool = false

    init(usingParentID: String) {
        library_id = usingParentID
    }

    func onAppear() {
        if viewDidLoad == true {
            return
        }
        viewDidLoad = true

        DispatchQueue.global(qos: .userInitiated).async {
            UserLibraryAPI.getLatestMedia(userId: SessionManager.current.user.user_id!, parentId: library_id, fields: [.primaryImageAspectRatio, .seriesPrimaryImage, .seasonUserData, .overview, .genres, .people], enableUserData: true, limit: 12)
                .sink(receiveCompletion: { completion in
                    print(completion)
                }, receiveValue: { response in
                    items = response
                })
                .store(in: &tempViewModel.cancellables)
        }
    }

    var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    Spacer().frame(width: 45)
                    ForEach(items, id: \.id) { item in
                        if item.type == "Series" || item.type == "Movie" {
                            NavigationLink(destination: LazyView { ItemView(item: item) }) {
                                PortraitItemElement(item: item)
                            }.buttonStyle(PlainNavigationLinkButtonStyle())
                        }
                    }
                    Spacer().frame(width: 45)
                }
            }.frame(height: 350)
            .onAppear(perform: onAppear)
    }
}
