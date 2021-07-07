import Combine
import JellyfinAPI
import SwiftUI

struct LibrarySearchView: View {
    @StateObject var viewModel: LibrarySearchViewModel
    @State var searchQuery = ""

    @State private var tracks: [GridItem] = Array(repeating: .init(.flexible()), count: Int(UIScreen.main.bounds.size.width) / 125)

    func recalcTracks() {
        tracks = Array(repeating: .init(.flexible()), count: Int(UIScreen.main.bounds.size.width) / 125)
    }

    var body: some View {
        VStack {
            Spacer().frame(height: 6)
            SearchBar(text: $searchQuery)
            ZStack {
                if !viewModel.isLoading {
                    ScrollView(.vertical) {
                        if !viewModel.items.isEmpty {
                            Spacer().frame(height: 16)
                            LazyVGrid(columns: tracks) {
                                ForEach(viewModel.items, id: \.id) { item in
                                    PortraitItemView(item: item)
                                }
                                Spacer().frame(height: 16)
                            }
                            .onRotate { _ in
                                recalcTracks()
                            }
                        } else {
                            Text("Query returned 0 results.")
                        }
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .onChange(of: searchQuery) { query in
            viewModel.searchQuerySubject.send(query)
        }
        .navigationBarTitle("Search", displayMode: .inline)
    }
}
