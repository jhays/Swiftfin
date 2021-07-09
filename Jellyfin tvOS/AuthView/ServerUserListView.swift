//
//  ServerUserListView.swift
//  Jellyfin
//
//  Created by Stephen Byatt on 30/5/21.
//

import Combine
import SwiftUI
import JellyfinAPI

class UserListViewModel: ViewModel {

    @Published var users = [UserDto]()

    override init() {
        super.init()
        fetchUsers()
    }

    func fetchUsers() {
        if ServerEnvironment.current.server != nil {
            UserAPI.getPublicUsers()
                .trackActivity(loading)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.errorMessage = "Could not connect to server"
                        print(error)
                        break
                    }
                }, receiveValue: { response in
                    self.users = response
                })
                .store(in: &cancellables)
            }
    }

    func authorise(user: UserDto) {
        SessionManager.current.login(username: user.name!, password: "")
            .trackActivity(loading)
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        if let err = error as? ErrorResponse {
                            switch err {
                                case .error(401, _, _, _):
                                    self.errorMessage = "Invalid credentials"
                                case .error:
                                    self.errorMessage = err.localizedDescription
                            }
                        }
                        break
                }
            }, receiveValue: { _ in

            })
            .store(in: &cancellables)
    }
}

struct ServerUserListView: View {

    @StateObject var viewModel = UserListViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                // Sretch frame to whole screen for background color
                Spacer()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack {
                    Text("Whos Watching?")
                        .font(.title)
                        .padding(.bottom, 30)
                    HStack {
                        ForEach(viewModel.users, id: \.id) { user in
                            // Link to manual sign in
                            if user.hasPassword ?? true {
                                NavigationLink(
                                    destination: CredentialEntryView(user)) {
                                    UserImageBoxView(user)
                                }
                                .buttonStyle(CardButtonStyle())

                            } else {
                                // Sign in without password
                                Button(action: {viewModel.authorise(user: user)}, label: {
                                    UserImageBoxView(user)
                                })
                                .buttonStyle(CardButtonStyle())

                            }
                        }

                        NavigationLink(
                            destination: CredentialEntryView()) {
                            VStack {
                                Image(systemName: "person.fill.badge.plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 300, height: 300)
                                    .scaleEffect(0.8)
                                    .foregroundColor(Color.init(white: 0.9))
                                Text("Sign in")
                                    .textCase(.uppercase)
                                    .padding(.bottom)
                            }
                        }
                        .buttonStyle(CardButtonStyle())
                    }
                    .padding(.top)
                }
            }
        }
        .alert(item: $viewModel.errorMessage) { _ in
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("Ok")))
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: Color.backgroundGradient),
                startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all))
    }

    struct UserImageBoxView: View {

        let user: UserDto

        init(_ user: UserDto) {
            self.user = user
        }
        private var profileImageURL: URL? {
            user.getUserProfileImageURL()

        }

        var body: some View {
            VStack {
                image
                    .overlay(Image(systemName: user.hasPassword ?? true ? "lock" : "lock.open" ).padding(2), alignment: .bottomLeading)
                Text(user.name ?? "User")
                    .padding(.bottom)
            }
        }

        /// URLImage
        private var image: some View {

            if let url = profileImageURL {
                return AnyView(ImageView(src: url)
                                .frame(width: 300, height: 300)
                )
            }

            return AnyView(placeholder)
        }

        /// Placeholder for loading URLImage
        private var placeholder: some View {
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: 300, height: 300)
                .scaledToFill()
                .scaleEffect(0.8)
                .background(Color.blue)
        }
    }
}
