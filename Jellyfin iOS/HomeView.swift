import Foundation
import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @State var showingSettings = false

    @ViewBuilder
    var innerBody: some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            ScrollView {
                VStack(alignment: .leading) {
                    if !viewModel.resumeItems.isEmpty {
                        ContinueWatchingView(items: viewModel.resumeItems)
                    }
                    if !viewModel.nextUpItems.isEmpty {
                        NextUpView(items: viewModel.nextUpItems)
                    }
                    if !viewModel.librariesShowRecentlyAddedIDs.isEmpty {
                        ForEach(viewModel.librariesShowRecentlyAddedIDs, id: \.self) { libraryID in
                            let library = viewModel.libraries.first(where: { $0.id == libraryID })
                            HStack {
                                Text("Latest \(library?.name ?? "")")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                                NavigationLink(destination: LazyView {
                                    LibraryView(viewModel: .init(parentID: libraryID, filters: viewModel.recentFilterSet), title: library?.name ?? "")
                                }) {
                                    HStack {
                                        Text("See All").font(.subheadline).fontWeight(.bold)
                                        Image(systemName: "chevron.right").font(Font.subheadline.bold())
                                    }
                                }
                            }.padding(.leading, 16)
                            .padding(.trailing, 16)
                            LatestMediaView(viewModel: .init(libraryID: libraryID))
                        }
                    }
                }
                .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 30)
            }
        }
    }

    var body: some View {
        innerBody
            .navigationTitle(MainTabView.Tab.home.localized)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .fullScreenCover(isPresented: $showingSettings) {
                SettingsView(viewModel: SettingsViewModel(), close: $showingSettings)
            }
    }
}
