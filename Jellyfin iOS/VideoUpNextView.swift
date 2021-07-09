import SwiftUI
import JellyfinAPI

class UpNextViewModel: ObservableObject {
    @Published var largeView: Bool = false
    @Published var item: BaseItemDto?
    weak var delegate: PlayerViewController?

    func nextUp() {
        if delegate != nil {
            delegate?.setPlayerToNextUp()
        }
    }
}

struct VideoUpNextView: View {

    @ObservedObject var viewModel: UpNextViewModel

    var body: some View {
        Button {
            viewModel.nextUp()
        } label: {
            HStack {
                VStack {
                    Text("Play Next")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(viewModel.item.getEpisodeLocator())
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                Image(systemName: "play.fill")
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
            .frame(width: 120, height: 35)
            .background(Color(red: 172 / 255, green: 92 / 255, blue: 195 / 255))
            .cornerRadius(10)
        }.buttonStyle(PlainButtonStyle())
        .frame(width: 120, height: 35)
        .shadow(color: .black, radius: 20)
    }
}
