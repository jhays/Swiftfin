//
//  PosterCollectionViewCell.swift
//  Jellyfin tvOS
//
//  Created by Stephen Byatt on 13/7/21.
//

import TVUIKit
import JellyfinAPI
import Nuke

class JellyfinPosterView: TVPosterView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class PosterCollectionViewCell: UICollectionViewCell {
    
    var posterView: TVPosterView
    var item: BaseItemDto?
    
    
    override init(frame: CGRect) {
        self.posterView = TVPosterView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
        
        super.init(frame: frame)

        addSubview(posterView)
        
      
        
        // go through posterview subviews to change the text tint
        
    }
    
    func setup(item: BaseItemDto) {
        self.item = item
        var imageURL: URL
        var title: String
        var subtitle: String?
        var blurhash: String
        
        if item.type == "Episode" {
            imageURL = item.getSeriesPrimaryImage(maxWidth: 500)
            title = item.seriesName ?? "Title"
            subtitle = item.name ?? "Subtitle"
            blurhash = item.getSeriesPrimaryImageBlurHash()
        } else {
            imageURL = item.getPrimaryImage(maxWidth: 500)
            title = item.name ?? "Title"
            if let year = item.productionYear {
                subtitle = String(year)
            }
            blurhash = item.getPrimaryImageBlurHash()

        }
        
        posterView.title = title
        posterView.subtitle = subtitle
//        posterView.image = UIImage(blurHash: blurhash, size: CGSize(width: 300, height: 500))
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        ImagePipeline.shared.loadImage(with: imageURL) { result in
            guard case let .success(image) = result else {
                dispatchGroup.leave()
                return
            }
            self.posterView.image = image.image
            dispatchGroup.leave()
        }
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
