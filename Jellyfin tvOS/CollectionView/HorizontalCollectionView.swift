//
//  HorizontalCollectionView.swift
//  Jellyfin tvOS
//
//  Created by Stephen Byatt on 10/7/21.
//

import SwiftUI
import UIKit
import JellyfinAPI

class MyCollectionViewCell: UICollectionViewCell {
    
    static var reuseIdentifier = "MyCollectionViewCell"
    
    private(set) var host: UIHostingController<PortraitItemElement>?
    
    func embed(in parent: UIViewController, withItem item: BaseItemDto) {
        if let host = self.host {
            host.rootView = PortraitItemElement(item: item)
            host.view.layoutIfNeeded()
        } else {
            let host = UIHostingController(rootView: PortraitItemElement(item: item))
            parent.addChild(host)
            host.didMove(toParent: parent)
            
            // alternative to using constraints
            host.view.frame = self.contentView.bounds
            self.contentView.addSubview(host.view)
            
            self.host = host
        }
    }
    
    deinit {
        host?.willMove(toParent: nil)
        host?.view.removeFromSuperview()
        host?.removeFromParent()
        host = nil
    }
}

class CollectionViewExample: UIViewController {
    
    var items: [BaseItemDto]
    
    init(items: [BaseItemDto]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(named: "Light")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: MyCollectionViewCell.reuseIdentifier)
        setupView()
    }
    
    private func setupView() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 16),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 16)
        ])
    }
}

extension CollectionViewExample: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.reuseIdentifier, for: indexPath) as? MyCollectionViewCell else {
            fatalError("Could not dequeue cell")
        }
        
        let item = items[indexPath.row]
        cell.embed(in: self, withItem: item)
        return cell
    }
}

extension CollectionViewExample: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 240, height: 320)
    }
}


struct collectionViewRepresentable: UIViewControllerRepresentable {
    let items: [BaseItemDto]
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let vc = CollectionViewExample(items: items)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        print("Updating collection view controller")
    }
    
}
