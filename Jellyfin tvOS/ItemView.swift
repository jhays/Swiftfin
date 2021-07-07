import SwiftUI
import Introspect
import JellyfinAPI

struct ItemView: View {
    private var item: BaseItemDto

    init(item: BaseItemDto) {
        self.item = item
    }

    var body: some View {
        Group {
            if item.type == "Movie" {
                MovieItemView(viewModel: .init(item: item))
            } else if item.type == "Series" {
                SeriesItemView(viewModel: .init(item: item))
            } else if item.type == "Season" {
                SeasonItemView(viewModel: .init(item: item))
            } else if item.type == "Episode" {
                EpisodeItemView(viewModel: .init(item: item))
            } else {
                Text("Type: \(item.type ?? "") not implemented yet :(")
            }
        }
    }
}
