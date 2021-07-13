//
//  PosterCollectionViewCell.swift
//  Jellyfin tvOS
//
//  Created by Stephen Byatt on 13/7/21.
//

import TVUIKit
import JellyfinAPI

class PosterCollectionViewCell: UICollectionViewCell {
    
    var posterView = TVPosterView(frame: .zero)
    var item: BaseItemDto?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print(frame)
    }
    
    func setup(item: BaseItemDto) {
        self.item = item
        var imageURL: URL
        var title: String
        var subtitle: String?
        
        if item.type == "Episode" {
            imageURL = item.getSeriesPrimaryImage(maxWidth: 500)
            title = item.seriesName ?? "Title"
            subtitle = item.name ?? "Subtitle"
        } else {
            imageURL = item.getPrimaryImage(maxWidth: 500)
            title = item.name ?? "Title"
        }
        
        posterView = TVPosterView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
        posterView.title = title
        if let subtitle = subtitle {
            posterView.subtitle = subtitle
        }
        if let imageData = NSData(contentsOf: imageURL) {
            if let artworkImage = UIImage(data: imageData as Data) {
                posterView.image = artworkImage
            }
        }
        
        addSubview(posterView)

        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
