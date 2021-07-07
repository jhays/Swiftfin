import SwiftUI

class SubtitlesViewController: InfoTabViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarItem.title = "Subtitles"

    }

    func prepareSubtitleView(subtitleTracks: [Subtitle], selectedTrack: Int32, delegate: VideoPlayerSettingsDelegate) {
        let contentView = UIHostingController(rootView: SubtitleView(selectedTrack: selectedTrack, subtitleTrackArray: subtitleTracks, delegate: delegate))
        self.view.addSubview(contentView.view)
        contentView.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentView.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        contentView.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

    }
}

struct SubtitleView: View {

    @State var selectedTrack: Int32 = -1
    @State var subtitleTrackArray: [Subtitle] = []

    weak var delegate: VideoPlayerSettingsDelegate?

    var body : some View {
        NavigationView {
            VStack {
                List(subtitleTrackArray, id: \.id) { track in
                    Button(action: {
                        delegate?.selectNew(subtitleTrack: track.id)
                        selectedTrack = track.id
                    }, label: {
                        HStack(spacing: 10) {
                            if track.id == selectedTrack {
                                Image(systemName: "checkmark")
                            } else {
                                Image(systemName: "checkmark")
                                    .hidden()
                            }
                            Text(track.name)
                        }
                    })

                }
            }
            .frame(width: 400)
            .frame(maxHeight: 400)

        }
    }

}
