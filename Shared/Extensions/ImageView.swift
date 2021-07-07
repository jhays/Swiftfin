import SwiftUI
import NukeUI

struct ImageView: View {
    private var source: URL = URL(string: "https://example.com")!
    private var blurhash: String = "001fC^"

    init(src: URL) {
        self.source = src
    }

    init(src: URL, bh: String) {
        self.source = src
        self.blurhash = bh
    }

    var body: some View {
        LazyImage(source: source)
        .placeholder {
            Image(uiImage: UIImage(blurHash: blurhash, size: CGSize(width: 8, height: 8))!)
                .resizable()
        }
        .failure {
            Rectangle()
                .background(Color.gray)
        }
    }
}
