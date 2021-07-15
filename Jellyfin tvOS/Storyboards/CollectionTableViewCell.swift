//
//  TableViewCell.swift
//  Jellyfin tvOS
//
//  Created by Stephen Byatt on 14/7/21.
//

import UIKit
import JellyfinAPI
import HorizontalStickyHeaderLayout

final class HeaderView: UICollectionReusableView {
    static let reuseID = "HeaderView"
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var container: UIView?
    @IBOutlet weak var containerTop: NSLayoutConstraint?

    func popHeader() {
        updateContainerTop(-20)
    }

    func unpopHeader() {
        updateContainerTop(0)
    }

    private func updateContainerTop(_ constant: CGFloat) {
        guard let containerTop = containerTop, containerTop.constant != constant else {
            return
        }

        containerTop.constant = constant
        self.layoutIfNeeded()
    }
}


class CollectionTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: HomeViewDelegate?
    
    var layout = HorizontalStickyHeaderLayout()
    
    var section: PosterCollectionSection = PosterCollectionSection()
    
    static func nib()-> UINib {
        return UINib(nibName: "CollectionTableViewCell", bundle: nil)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layout = HorizontalStickyHeaderLayout()
        layout.delegate = self
        layout.contentInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)

        
        collectionView.collectionViewLayout = layout
        collectionView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 600)
        collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(PosterCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.collectionView.register(UINib(nibName: "HeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.section.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PosterCollectionViewCell
        
        // Configure the cell
        let item = self.section.items[indexPath.row]
        cell.setup(item: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as? HeaderView{
            sectionHeader.label!.text = section.title
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: -200, bottom: 0, right: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.section.items[indexPath.row]
        delegate?.showItemView(for: item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    
    
    
    func configure(with section: PosterCollectionSection) {
        self.section = section
        self.collectionView.reloadData()
    }
    
}

// MARK: HorizontalStickyHeaderLayoutDelegate
extension CollectionTableViewCell: HorizontalStickyHeaderLayoutDelegate {
    
    // Popping Header
    func collectionView(_ collectionView: UICollectionView, hshlDidUpdatePoppingHeaderIndexPaths indexPaths: [IndexPath]) {
        let unpopDuration: Double = 0.4
        let (pop, unpop) = self.getHeaders(poppingHeadersIndexPaths: self.layout.poppingHeaderIndexPaths)
        UIView.animate(withDuration: unpopDuration, delay: 0, options: [.curveEaseOut], animations: {
            unpop.forEach { $0.unpopHeader() }
            pop.forEach { $0.popHeader() }
        }, completion: nil)
    }
    
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        layout.updatePoppingHeaderIndexPaths()
        let unpopDuration: Double = 0.4

        let (pop, unpop) = self.getHeaders(poppingHeadersIndexPaths: self.layout.poppingHeaderIndexPaths)
        UIView.animate(withDuration: unpopDuration, delay: 0, options: [.curveEaseOut], animations: {
            unpop.forEach { $0.unpopHeader() }
        }, completion: nil)
        coordinator.addCoordinatedAnimations({
            pop.forEach { $0.popHeader() }
        }, completion: nil)
        super.didUpdateFocus(in: context, with: coordinator)
    }
    
    // Size
    func collectionView(_ collectionView: UICollectionView, hshlSizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 500)
    }

    func collectionView(_ collectionView: UICollectionView, hshlSizeForHeaderAtSection section: Int) -> CGSize {
        let size = self.section.title.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 38, weight: .bold)])
        return CGSize(width: size.width, height: 20)
    }

    // Spacing
    func collectionView(_ collectionView: UICollectionView, hshlMinSpacingForCellsAtSection section: Int) -> CGFloat {
        return 10
    }

    // Insets
    func collectionView(_ collectionView: UICollectionView, hshlHeaderInsetsAtSection section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 10, bottom: 5, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView, hshlSectionInsetsAtSection section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    func getHeaders(poppingHeadersIndexPaths indexPaths: [IndexPath]) -> (pop: [HeaderView], unpop: [HeaderView]) {
        var visible = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader)
        var pop: [HeaderView] = []
        for indexPath in indexPaths {
            guard let view = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) else {
                continue
            }
            if let index = visible.firstIndex(of: view) {
                visible.remove(at: index)
            }
            if let header = view as? HeaderView {
                pop.append(header)
            }
        }
        return (pop: pop, unpop: visible.compactMap { $0 as? HeaderView })
    }
}
