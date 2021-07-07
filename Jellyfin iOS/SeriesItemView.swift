import SwiftUI

struct SeriesItemView: View {
    @StateObject var viewModel: SeriesItemViewModel

    @State private var tracks: [GridItem] = Array(repeating: .init(.flexible()), count: Int(UIScreen.main.bounds.size.width) / 125)

    func recalcTracks() {
        tracks = Array(repeating: .init(.flexible()), count: Int(UIScreen.main.bounds.size.width) / 125)
    }

    var body: some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            ScrollView(.vertical) {
                Spacer().frame(height: 16)
                LazyVGrid(columns: tracks) {
                    ForEach(viewModel.seasons, id: \.id) { season in
                        PortraitItemView(item: season)
                    }
                    Spacer().frame(height: 2)
                }.onRotate { _ in
                    recalcTracks()
                }
            }
            .overrideViewPreference(.unspecified)
            .navigationTitle(viewModel.item.name ?? "")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
