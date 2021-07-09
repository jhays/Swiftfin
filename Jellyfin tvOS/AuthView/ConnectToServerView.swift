import JellyfinAPI
import SwiftUI

struct ConnectToServerView: View {
    @State var isServerConnected: Bool

    init() {
        isServerConnected = ServerEnvironment.current.server != nil
    }
    var body: some View {

        if isServerConnected {
            // If server is saved in settings
            ServerUserListView()
        } else {
            // Show server discovery 
            ServerSelectionView()
        }
    }
}
