//
//  ServerSelectionManView.swift
//  ABJC
//
//  Created by Noah Kamara on 26.03.21.
//

import SwiftUI

extension ServerSelectionView {
    struct ManualView: View {

        @StateObject var viewModel = ServerSelectionViewModel()

        /// Server Host
        @State var host: String = ""

        /// Server Port
        @State var port: String = "8096"

        /// Server Path
        @State var path: String = ""

        /// HTTPS enabled
        @State var isHttpsEnabled: Bool = false

        @State var serverSelected = false

        var body: some View {
            GeometryReader { geometry in
                HStack {
                    VStack {
                        Image("logo_wide")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(0.75)
                    }
                    .frame(width: geometry.size.width * 1/2)

                    VStack(alignment: .center) {
                        VStack {
                            HStack(spacing: 5) {
                                Spacer()
                                    .frame(width: 200)
                                Text("Server Selection")
                                    .font(.title2).bold()
                                Spacer()
                                    .frame(width: 200)

                            }
                            Group {
                                TextField("Host", text: self.$host)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)

                                TextField("Port", text: self.$port)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .textContentType(.oneTimeCode)
                                    .keyboardType(.numberPad)

                                TextField("Path", text: self.$path)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)

                                Toggle("HTTPS", isOn: $isHttpsEnabled)

                                Button {
                                    var path: String?

                                    if !self.path.isEmpty {
                                        path = self.path
                                        // Ensure users have not entered a '/'
                                        if path!.contains("/") {
                                            path?.removeFirst()
                                        }
                                    }

                                    let url = URL(string: "http://\(host):\(port)/\(path ?? "")")!
                                    viewModel.setServer(url: url) {
                                        self.serverSelected = true
                                    }
                                } label: {
                                    Text("Continue").textCase(.uppercase)
                                }
                                .background(
                                    NavigationLink(
                                        destination: CredentialEntryView(),
                                        isActive: $serverSelected) {
                                        EmptyView()
                                    }
                                    .buttonStyle(PlainButtonStyle()))

                            }
                        }
                        .frame(maxHeight: .infinity)

                    }
                    .frame(width: geometry.size.width * 1/2)
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: Color.backgroundGradient),
                    startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all))

        }
    }

    struct ServerSelectionManView_Previews: PreviewProvider {
        static var previews: some View {
            ManualView()
        }
    }
}
