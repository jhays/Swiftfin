import SwiftUI
import Combine
import JellyfinAPI

struct NextUpView: View {

    var items: [BaseItemDto]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Next Up")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.leading, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(items, id: \.id) { item in
                        PortraitItemView(item: item)
                    }.padding(.trailing, 16)
                }
                .padding(.leading, 20)
            }
            .frame(height: 200)
        }
    }
}
