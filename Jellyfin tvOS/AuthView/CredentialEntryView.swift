//
//  CredentialEntryView.swift
//  ABJC
//
//  Created by Noah Kamara on 26.03.21.
//

import SwiftUI
import JellyfinAPI

class CredentialEntryViewModel: ViewModel {

    func authorise(username: String, password: String) {
        print("Auhtorising")
        SessionManager.current.login(username: username, password: password)
            .trackActivity(loading)
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.errorMessage = "Invalid credentials"
                        print(error)
                        break
                }
            }, receiveValue: { res in
                print(res)
            })
            .store(in: &cancellables)
    }

}

struct CredentialEntryView: View {
    @Namespace private var namespace
    @State var profileImageURL: URL?

    /// Credentials: username
    @State var username: String = ""

    /// Credentials: password
    @State var password: String = ""

    @State var showingAlert: Bool = false

    @State var isCredentialsFilledIn: Bool = false

    var user: UserDto?

    @StateObject var viewModel = CredentialEntryViewModel()

    init(_ user: UserDto? = nil) {
        self.user = user
    }

    var body: some View {

        ZStack {
            // Sretch frame to whole screen for background color
            Spacer()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(alignment: .center) {
                Group {
                    if profileImageURL != nil {
                        profileImageView
                    } else {
                        personImageView
                    }
                }.padding(20)

                VStack {
                    Group {
                        TextField("Username", text: self.$username)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textContentType(.username)
                            .prefersDefaultFocus(username.isEmpty, in: namespace)
                            .disabled(user != nil)

                        SecureField("Password", text: self.$password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textContentType(.password)
                            .prefersDefaultFocus(!username.isEmpty, in: namespace)
                    }.frame(width: 400)

                    Button {
                        viewModel.authorise(username: username, password: password)
                    } label: {
                        Text("Login").textCase(.uppercase)
                    }
                    .prefersDefaultFocus(!username.isEmpty && !password.isEmpty, in: namespace)
                    .disabled(username.isEmpty)
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
        .onAppear(perform: setupImageURL)

    }

    func setupImageURL() {
        if let user = user {
            username = user.name!
            self.profileImageURL = user.getUserProfileImageURL()
        }
    }

    var personImageView: some View {
        let imageName = user == nil ? "person.fill.badge.plus" : "person.fill"

        return Image(systemName: imageName)
            .resizable()
            .frame(width: 300, height: 300)
            .scaledToFill()
            .scaleEffect(0.8)
            .background(user == nil ? Color.clear : Color.blue)
            .cornerRadius(20)

    }

    var profileImageView: some View {

        if let url = profileImageURL {
            return AnyView(ImageView(src: url)
                            .frame(width: 300, height: 300)
            )
        }

        return AnyView(personImageView)
    }

}
