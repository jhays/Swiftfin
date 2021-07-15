//
//  HomeTableViewController.swift
//  Jellyfin tvOS
//
//  Created by Stephen Byatt on 14/7/21.
//

import UIKit
import JellyfinAPI
import Combine

class HomeTableViewController: UITableViewController {

    var itemCollections: [[BaseItemDto]] = []
    var cancellables = Set<AnyCancellable>()
    weak var delegate: HomeViewDelegate?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CollectionTableViewCell.nib(), forCellReuseIdentifier: "TableCell")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        ItemsAPI.getResumeItems(userId: SessionManager.current.user.user_id!, limit: 12,
                                fields: [.primaryImageAspectRatio, .seriesPrimaryImage, .seasonUserData, .overview, .genres, .people],
                                mediaTypes: ["Video"], imageTypeLimit: 1, enableImageTypes: [.primary, .backdrop, .thumb])
            .sink(receiveCompletion: { completion in
            }, receiveValue: { response in
                if let items = response.items {
                    self.itemCollections.append(items)

                }
                TvShowsAPI.getNextUp(userId: SessionManager.current.user.user_id!, limit: 12,
                                     fields: [.primaryImageAspectRatio, .seriesPrimaryImage, .seasonUserData, .overview, .genres, .people])
                    .sink(receiveCompletion: { completion in
                    }, receiveValue: { response in
                        if let items = response.items {
                            self.itemCollections.append(items)

                        }
                        
                        self.tableView.reloadData()
//                        print(self.itemCollections)
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
        let items = itemCollections[indexPath.row]
        cell.configure(with: items)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 600
    }
    
    override func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
