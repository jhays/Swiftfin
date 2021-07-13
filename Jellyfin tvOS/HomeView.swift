//import Foundation
//import SwiftUI

import SwiftUI
import JellyfinAPI

protocol HomeViewDelegate: AnyObject {
    func showItemView(for item: BaseItemDto)
}

struct HomeView: UIViewControllerRepresentable {
    @StateObject var viewModel = HomeViewModel()
    @Binding var itemToShow: BaseItemDto
    @Binding var showItemView: Bool

//    func makeUIViewController(context: Context) -> HomeViewController {
//
//        let storyboard = UIStoryboard(name: "HomeView", bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier: "HomeView") as! HomeViewController
//        viewController.items = viewModel.libraries
//        print("setting up homeview controller")
//        return viewController
//    }
//
//    func updateUIViewController(_ uiViewController: HomeViewController, context: Context) {
//        uiViewController.update(items: viewModel.nextUpItems)
//        print("updating homeview controller")
//        uiViewController.posterCollectionVC.collectionView.reloadData()
//
//    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<HomeView>) -> PosterCollectionViewController {

        let storyboard = UIStoryboard(name: "HomeView", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "postercollection") as! PosterCollectionViewController
        print("setting up homeview controller")
        viewController.delegate = context.coordinator
       
        return viewController
    }

    func updateUIViewController(_ uiViewController: PosterCollectionViewController, context: UIViewControllerRepresentableContext<HomeView>) {
        if uiViewController.items.isEmpty && !viewModel.nextUpItems.isEmpty {
            uiViewController.items = viewModel.nextUpItems
            let width = 1920*3
            let size = uiViewController.collectionView.contentSize
            uiViewController.collectionView.contentSize = CGSize(width: CGFloat(width), height: size.height)
            print(uiViewController.preferredContentSize)
            print(uiViewController.collectionView.contentSize)
            print(uiViewController.view.frame)
            uiViewController.collectionView.reloadData()
            print("updating homeview controller")
        }

    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(itemToShow: self.$itemToShow, showItemView: self.$showItemView)
       }

    class Coordinator: NSObject, HomeViewDelegate {
        let itemToShow: Binding<BaseItemDto>
        let showItemView: Binding<Bool>
        
        init(itemToShow: Binding<BaseItemDto>, showItemView: Binding<Bool>) {
            self.itemToShow = itemToShow
            self.showItemView = showItemView
        }
        
        func showItemView(for item: BaseItemDto) {
            itemToShow.wrappedValue = item
            showItemView.wrappedValue = true
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
