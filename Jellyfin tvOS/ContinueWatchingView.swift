import SwiftUI
import JellyfinAPI
import Combine

struct ContinueWatchingView: View {
    var items: [BaseItemDto]
    @Namespace private var namespace

    var body: some View {
        VStack(alignment: .leading) {
            if items.count > 0 {
                Text("Continue Watching")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.leading, 90)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        Spacer().frame(width: 45)
                        ForEach(items, id: \.id) { item in
                            NavigationLink(destination: LazyView { ItemView(item: item) }) {
                                LandscapeItemElement(item: item)
                            }
                            .buttonStyle(PlainNavigationLinkButtonStyle())
                        }
                        Spacer().frame(width: 45)
                    }
                }.frame(height: 330)
            } else {
                EmptyView()
            }
        }
    }
}
