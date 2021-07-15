//
//  HomeTableViewController.swift
//  Jellyfin tvOS
//
//  Created by Stephen Byatt on 14/7/21.
//

import UIKit
import JellyfinAPI
import Combine

struct PosterCollectionSection {
    var title: String
    var items: [BaseItemDto]
    
    init(title : String = "", items: [BaseItemDto] = []) {
        self.title = title
        self.items = items
    }
}

class HomeTableViewController: UITableViewController {

    var itemCollections: [PosterCollectionSection] = []
    var cancellables = Set<AnyCancellable>()
    weak var delegate: HomeViewDelegate?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CollectionTableViewCell.nib(), forCellReuseIdentifier: "TableCell")
        

        // Currently unabailable wiht hosting controllers and SwiftUI
        //self.navigationController?.tabBarObservedScrollView = self.tableView
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        ItemsAPI.getResumeItems(userId: SessionManager.current.user.user_id!, limit: 12,
                                fields: [.primaryImageAspectRatio, .seriesPrimaryImage, .seasonUserData, .overview, .genres, .people],
                                mediaTypes: ["Video"], imageTypeLimit: 1, enableImageTypes: [.primary, .backdrop, .thumb])
            .sink(receiveCompletion: { completion in
            }, receiveValue: { response in
                if let items = response.items {
                    let section = PosterCollectionSection(title: "Continue Watching", items: items)
                    self.itemCollections.append(section)

                }
                TvShowsAPI.getNextUp(userId: SessionManager.current.user.user_id!, limit: 12,
                                     fields: [.primaryImageAspectRatio, .seriesPrimaryImage, .seasonUserData, .overview, .genres, .people])
                    .sink(receiveCompletion: { completion in
                    }, receiveValue: { response in
                        if let items = response.items {
                            let section = PosterCollectionSection(title: "Next Up", items: items)
                            self.itemCollections.append(section)
                        }
                        var libraries: [BaseItemDto] = []
                        UserViewsAPI.getUserViews(userId: SessionManager.current.user.user_id!)
                            .sink(receiveCompletion: { completion in
                            }, receiveValue: { response in
                                response.items!.forEach { item in
                                    if item.collectionType == "movies" || item.collectionType == "tvshows" {
                                        libraries.append(item)
                                    }
                                }

                                UserAPI.getCurrentUser()
                                    .sink(receiveCompletion: { completion in
                                    }, receiveValue: { response in
                                        libraries.forEach { library in
                                            if !(response.configuration?.latestItemsExcludes?.contains(library.id!))! {
                                                UserLibraryAPI.getLatestMedia(userId: SessionManager.current.user.user_id!, parentId: library.id, fields: [.primaryImageAspectRatio, .seriesPrimaryImage, .seasonUserData, .overview, .genres, .people], enableUserData: true, limit: 12)
                                                    .sink(receiveCompletion: { completion in
                                                    }, receiveValue: { response in
                                                        let section = PosterCollectionSection(title: "Recently Added \(library.name ?? "")", items: response)
                                                        self.itemCollections.append(section)
                                                        self.tableView.reloadData()
                                                        self.delegate?.loading(false)

                                                    })
                                                    .store(in: &self.cancellables)
                                            }
                                        }
                                    })
                                    .store(in: &self.cancellables)
                            })
                            .store(in: &self.cancellables)
                        
                    })
                    .store(in: &self.cancellables)

            })
            .store(in: &cancellables)
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemCollections.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! CollectionTableViewCell
        cell.delegate = self.delegate
        let section = itemCollections[indexPath.row]
        cell.configure(with: section)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 600
    }
    
    override func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
