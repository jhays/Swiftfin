//
//  HomeViewController.swift
//  Jellyfin tvOS
//
//  Created by Stephen Byatt on 13/7/21.
//

import UIKit
import JellyfinAPI

class HomeViewController: UIViewController {

    @IBOutlet var StackView: UIView!
    var posterCollectionVC = PosterCollectionViewController()
    
    var items: [BaseItemDto] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: 300, height: 500)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 60.0
        flowLayout.minimumLineSpacing = 1000.0
        
        posterCollectionVC = PosterCollectionViewController(collectionViewLayout: flowLayout)
        posterCollectionVC.items = items
        posterCollectionVC.view.clipsToBounds = false
        
        addChild(posterCollectionVC)
        StackView.addSubview(posterCollectionVC.view)

        // Do any additional setup after loading the view.
    }
    
    func update(items: [BaseItemDto]) {
        posterCollectionVC.items = items
        let width = items.count * 300 + 20
        let height = posterCollectionVC.collectionView.contentSize.height
        posterCollectionVC.collectionView.contentSize = CGSize(width: CGFloat(width), height: height)
        posterCollectionVC.preferredContentSize = CGSize(width: CGFloat(width), height: height)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
