import SwiftUI
import WidgetKit
import KeychainSwift

@main
struct JellyfinWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        NextUpWidget()
    }
}
