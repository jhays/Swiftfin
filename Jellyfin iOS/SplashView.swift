import SwiftUI

struct SplashView: View {
    @StateObject var viewModel = SplashViewModel()

    var body: some View {
        if viewModel.isLoggedIn {
            MainTabView()
        } else {
            NavigationView {
                ConnectToServerView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
