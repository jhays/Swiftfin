
//struct ItemView: View {
//    private var item: BaseItemDto
//
//    init(item: BaseItemDto) {
//        self.item = item
//    }
//
//    var body: some View {
//        Group {
//            if item.type == "Movie" {
//                MovieItemView(viewModel: .init(item: item))
//            } else if item.type == "Series" {
//                SeriesItemView(viewModel: .init(item: item))
//            } else if item.type == "Season" {
//                SeasonItemView(viewModel: .init(item: item))
//            } else if item.type == "Episode" {
//                EpisodeItemView(viewModel: .init(item: item))
//            } else {
//                Text("Type: \(item.type ?? "") not implemented yet :(")
//            }
//        }
//    }
//}


import SwiftUI
import JellyfinAPI
import Introspect

class ItemViewModel : ObservableObject {
    let item: BaseItemDto
    
    @Published var showVideoPlayer = false
    
    init(item: BaseItemDto) {
        self.item = item
    }
    
    func getTitle() -> String {
        if item.type == "Episode" {
            return "S\(item.parentIndexNumber ?? 0) • E\(item.indexNumber ?? 0) - \(item.name ?? "")"
        }
        else {
            return item.name!
        }
    }
    
    func getYearOrDate() -> String {
        if item.type == "Episode" {
            if let dateString = item.premiereDateToString() {
                return dateString
            }
        }
        return String(item.productionYear!)
    }
    
    func getImageURL(width: CGFloat) -> URL {
        if item.type == "Episode"
        {
            return item.getSeriesBackdropImage(maxWidth: Int(width))
        } else {
            return item.getBackdropImage(maxWidth: Int(width))
        }
    }
    
    func getImageBlurhash() -> String {
        if item.type == "Episode"
        {
            return item.getSeriesBackdropImageBlurHash()
        } else {
            return item.getBackdropImageBlurHash()
        }
    }
}

struct ItemView: View {
    @ObservedObject var viewModel : ItemViewModel
    
    init(item: BaseItemDto) {
        viewModel = ItemViewModel(item: item)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                topImage(viewModel: viewModel)
                // If item is episode show the season to scroll through horizontally
                Button("Test") {
                    
                }
                
                // Actor row
                
                // Related media row
            }
        }
    }
    
    struct topImage: View {
        @ObservedObject var viewModel : ItemViewModel
        
        var body: some View {
            ZStack {
                image
                VStack(alignment: .leading) {
                    Spacer()
                    
                    Text(viewModel.getTitle())
                        .font(.title2)
                        .shadow(radius: 15)
                    
                    HStack {
                        NavigationLink(destination: VideoPlayerView(item: viewModel.item)) {
                            Text("Play")
                                .padding(.horizontal, 50)
                        }
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text(viewModel.item.getItemRuntime())
                                Text(viewModel.getYearOrDate())
                                if let rating = viewModel.item.officialRating {
                                    Text(rating)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(EdgeInsets(top: 1, leading: 4, bottom: 1, trailing: 4))
                                        .overlay(RoundedRectangle(cornerRadius: 2)
                                                    .stroke(Color.secondary, lineWidth: 1))
                                }
                            }
                            .padding(.vertical)
                            
                            Text(viewModel.item.overview ?? "")
                        }
                        
                        Spacer()
                        
                    }
                    
                }
                .padding([.leading, .bottom], 100)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(gradient: Gradient(colors: [.black, .black.opacity(0)]), startPoint: .bottom, endPoint: .top))
            }
        }
        
        var image : some View {
            let width = UIScreen.main.bounds.width
            return ImageView(src: viewModel.getImageURL(width: width), bh: viewModel.getImageBlurhash())
                .frame(width: width, height: UIScreen.main.bounds.height)
        }
        
    }
    
}
