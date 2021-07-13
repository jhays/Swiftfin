import SwiftUI
import JellyfinAPI

struct PortraitItemElement: View {
    @Environment(\.isFocused) var envFocused: Bool
    @State var focused: Bool = false
    @State var backgroundURL: URL?

    var item: BaseItemDto
    
    var imageURL: URL {
        if item.type == "Episode" {
            return item.getSeriesPrimaryImage(maxWidth: 200)
        }
        else {
            return item.getPrimaryImage(maxWidth: 200)
        }
    }
    
    var imageBlurHash: String {
        if item.type == "Episode" {
            return item.getSeriesPrimaryImageBlurHash()
        }
        else {
            return item.getPrimaryImageBlurHash()
        }
    }

    var body: some View {
        VStack {
            ImageView(src: imageURL, bh: imageBlurHash)
                .frame(width: 200, height: 300)
                .cornerRadius(10)
                .shadow(radius: focused ? 10.0 : 0)
                .shadow(radius: focused ? 10.0 : 0)
                .overlay(favouriteIcon, alignment: .bottomLeading)
                .overlay(episodeOverlay, alignment: .topTrailing)
                .opacity(1)
            
        }
        .frame(width: 200)
        .onChange(of: envFocused) { envFocus in
            withAnimation(.linear(duration: 0.15)) {
                self.focused = envFocus
            }
        }
//        .scaleEffect(focused ? 1.1 : 1)
    }
    
    
    var favouriteIcon: some View {
        ZStack {
            if item.userData?.isFavorite ?? false {
                Image(systemName: "circle.fill")
                    .foregroundColor(.white)
                    .opacity(0.6)
                Image(systemName: "heart.fill")
                    .foregroundColor(Color(.systemRed))
                    .font(.system(size: 10))
            }
        }
        .padding(2)
        .opacity(1)
    }
    
    var episodeOverlay: some View {
        let played = item.userData?.played ?? false
        let unplayedCount = item.userData?.unplayedItemCount
        
        return ZStack {
            if played {
                episodeOverlayBackground
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(.systemBlue))
            }
            else if let count = unplayedCount{
                episodeOverlayBackground
                Text(String(count))
                    .foregroundColor(.white)
                    .font(.system(size: 20))
            }
        }.padding(10)
    }
    
    var episodeOverlayBackground: some View {
        return Circle()
            .frame(width: 30, height: 30)
            .foregroundColor(.black)
            .scaleEffect(1.3)
            .opacity(0.6)
    }
}
