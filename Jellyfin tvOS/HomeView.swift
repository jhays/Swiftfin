import Foundation
import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()

    @State var showingSettings = false

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
            } else {
                LazyVStack(alignment: .leading) {
                    Button {
                        let nc = NotificationCenter.default
                        nc.post(name: Notification.Name("didSignOut"), object: nil)
                    } label: {
                        HStack {
                            ImageView(src: URL(string: "\(ServerEnvironment.current.server.baseURI ?? "")/Users/\(SessionManager.current.user.user_id!)/Images/Primary?width=500")!)
                                .frame(width: 50, height: 50)
                                .cornerRadius(25.0)
                            Text(SessionManager.current.user.username ?? "")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }.padding(.leading, 90)
                    if !viewModel.resumeItems.isEmpty {
                        ContinueWatchingView(items: viewModel.resumeItems)
                    }
                    if !viewModel.nextUpItems.isEmpty {
                        NextUpView(items: viewModel.nextUpItems)
                    }

                    if !viewModel.librariesShowRecentlyAddedIDs.isEmpty {
                        ForEach(viewModel.librariesShowRecentlyAddedIDs, id: \.self) { libraryID in
                            VStack(alignment: .leading) {
                                let library = viewModel.libraries.first(where: { $0.id == libraryID })

                                NavigationLink(destination: LazyView {
                                    LibraryView(viewModel: .init(parentID: libraryID, filters: viewModel.recentFilterSet), title: library?.name ?? "")
                                }) {
                                    HStack {
                                        Text("Latest \(library?.name ?? "")")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        Image(systemName: "chevron.forward.circle.fill")
                                    }
                                }.padding(EdgeInsets(top: 0, leading: 90, bottom: 0, trailing: 0))
                                LatestMediaView(usingParentID: libraryID)
                            }
                        }
                    }
                    Spacer().frame(height: 30)
                }
            }
        }
    }
}
