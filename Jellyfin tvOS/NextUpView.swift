import SwiftUI
import JellyfinAPI
import Combine

struct NextUpView: View {
    var items: [BaseItemDto]

    var body: some View {
        VStack(alignment: .leading) {
            if items.count > 0 {
                Text("Next Up")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.leading, 90)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        Spacer().frame(width: 45)
                        ForEach(items, id: \.id) { item in
                            NavigationLink(destination: LazyView { ItemView(item: item) }) {
                                LandscapeItemElement(item: item)
                            }.buttonStyle(PlainNavigationLinkButtonStyle())
                        }
                        Spacer().frame(width: 45)
                    }
                }.frame(height: 330)
                .offset(y: -10)
            } else {
                EmptyView()
            }
        }
    }
}
