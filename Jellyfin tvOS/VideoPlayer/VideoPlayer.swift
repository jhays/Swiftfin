import SwiftUI
import JellyfinAPI

struct VideoPlayerView: UIViewControllerRepresentable {
    var item: BaseItemDto

    func makeUIViewController(context: Context) -> some UIViewController {

        let storyboard = UIStoryboard(name: "VideoPlayer", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "VideoPlayer") as! VideoPlayerViewController
        viewController.manifest = item

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }
}
