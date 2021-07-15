//import Foundation
//import SwiftUI

import SwiftUI
import JellyfinAPI

protocol HomeViewDelegate: AnyObject {
    func showItemView(for item: BaseItemDto)
    func loading(_ val: Bool)
}

struct HomeView: UIViewControllerRepresentable {
//        @StateObject var viewModel = HomeViewModel()
    @Binding var itemToShow: BaseItemDto
    @Binding var showItemView: Bool
    @Binding var loading: Bool
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<HomeView>) -> HomeTableViewController {
        
        let vc = HomeTableViewController()
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: HomeTableViewController, context: UIViewControllerRepresentableContext<HomeView>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(itemToShow: self.$itemToShow, showItemView: self.$showItemView, loading: self.$loading)
    }
    
    class Coordinator: NSObject, HomeViewDelegate {
        let itemToShow: Binding<BaseItemDto>
        let showItemView: Binding<Bool>
        let loading: Binding<Bool>

        init(itemToShow: Binding<BaseItemDto>, showItemView: Binding<Bool>, loading: Binding<Bool>) {
            self.itemToShow = itemToShow
            self.showItemView = showItemView
            self.loading = loading
        }
        
        func showItemView(for item: BaseItemDto) {
            itemToShow.wrappedValue = item
            showItemView.wrappedValue = true
        }
        
        func loading(_ val: Bool) {
            self.loading.wrappedValue = val
        }
    }
    
    func showItemView(for item: BaseItemDto) {
        itemToShow = item
        showItemView = true
    }
}



//struct HomeView: View {
//    @StateObject var viewModel = HomeViewModel()
//
//    @State var showingSettings = false
//
//    var body: some View {
//        ScrollView {
//            if viewModel.isLoading {
//                ProgressView()
//            } else {
//                LazyVStack(alignment: .leading) {
//                    Button {
//                        let nc = NotificationCenter.default
//                        nc.post(name: Notification.Name("didSignOut"), object: nil)
//                    } label: {
//                        HStack {
//                            ImageView(src: URL(string: "\(ServerEnvironment.current.server.baseURI ?? "")/Users/\(SessionManager.current.user.user_id!)/Images/Primary?width=500")!)
//                                .frame(width: 50, height: 50)
//                                .cornerRadius(25.0)
//                            Text(SessionManager.current.user.username ?? "")
//                                .font(.headline)
//                                .fontWeight(.semibold)
//                        }
//                    }.padding(.leading, 90)
//
//                    if !viewModel.resumeItems.isEmpty {
//                        ContinueWatchingView(items: viewModel.resumeItems)
//                    }
//                    if !viewModel.nextUpItems.isEmpty {
//                        NextUpView(items: viewModel.nextUpItems)
//                    }
//
//                    if !viewModel.librariesShowRecentlyAddedIDs.isEmpty {
//                        ForEach(viewModel.librariesShowRecentlyAddedIDs, id: \.self) { libraryID in
//                            VStack(alignment: .leading) {
//                                let library = viewModel.libraries.first(where: { $0.id == libraryID })
//
//                                // Title Link
//                                NavigationLink(destination: LazyView {
//                                    LibraryView(viewModel: .init(parentID: libraryID, filters: viewModel.recentFilterSet), title: library?.name ?? "")
//                                }) {
//                                    HStack {
//                                        Text("Recently added \(library?.name ?? "")")
//                                        .font(.headline)
//                                        .fontWeight(.semibold)
//                                        Image(systemName: "chevron.forward.circle.fill")
//                                    }
//                                }.padding(EdgeInsets(top: 0, leading: 90, bottom: 0, trailing: 0))
//
//                                // Row content
//                                LatestMediaView(usingParentID: libraryID)
//                            }
//                        }
//                    }
//                    Spacer().frame(height: 30)
//                }
//            }
//        }
//    }
//}
