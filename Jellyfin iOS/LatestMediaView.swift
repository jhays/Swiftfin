import SwiftUI

struct LatestMediaView: View {
    @StateObject var viewModel: LatestMediaViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(viewModel.items, id: \.id) { item in
                    if item.type == "Series" || item.type == "Movie" {
                        PortraitItemView(item: item)
                    }
                }.padding(.trailing, 16)
            }.padding(.leading, 20)
        }.frame(height: 200)
    }
}
