import SwiftUI

struct SplashView: View {
    @StateObject var viewModel = SplashViewModel()

    var body: some View {
        Group {
            if viewModel.isLoggedIn {
                NavigationView {
                    MainTabView()
                }.padding(.all, -1)
            } else {
                NavigationView {
                    ConnectToServerView()
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
}
