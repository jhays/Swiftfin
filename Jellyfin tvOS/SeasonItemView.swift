import SwiftUI
import JellyfinAPI
import SwiftUIFocusGuide

struct SeasonItemView: View {
    @ObservedObject var viewModel: SeasonItemViewModel
    @State var wrappedScrollView: UIScrollView?;
    
    @StateObject var focusBag = SwiftUIFocusBag()
    
    @Environment(\.resetFocus) var resetFocus
    @Namespace private var namespace
    
    var body: some View {
        ZStack {
            ImageView(src: viewModel.item.getSeriesBackdropImage(maxWidth: 1920), bh: viewModel.item.getSeriesBackdropImageBlurHash())
                .opacity(0.4)
            ScrollView {
                LazyVStack(alignment: .leading) {
                    Text("\(viewModel.item.seriesName ?? "") • \(viewModel.item.name ?? "")")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    HStack {
                        if(viewModel.item.productionYear != nil) {
                            Text(String(viewModel.item.productionYear!)).font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        if viewModel.item.officialRating != nil {
                            Text(viewModel.item.officialRating!).font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .padding(EdgeInsets(top: 1, leading: 4, bottom: 1, trailing: 4))
                                .overlay(RoundedRectangle(cornerRadius: 2)
                                    .stroke(Color.secondary, lineWidth: 1))
                        }
                        if viewModel.item.communityRating != nil {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.subheadline)
                                Text(String(viewModel.item.communityRating!)).font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        if(!(viewModel.item.taglines ?? []).isEmpty) {
                            Text(viewModel.item.taglines?.first ?? "")
                                .font(.body)
                                .italic()
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        Text(viewModel.item.overview ?? "")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        HStack {
                            VStack {
                                Button {
                                    viewModel.updateFavoriteState()
                                } label: {
                                    MediaViewActionButton(icon: "heart.fill", scrollView: $wrappedScrollView, iconColor: viewModel.isFavorited ? .red : .white)
                                }.prefersDefaultFocus(in: namespace)
                                Text(viewModel.isFavorited ? "Unfavorite" : "Favorite")
                                    .font(.caption)
                            }

                            VStack {
                                Button {
                                    viewModel.updateWatchState()
                                } label: {
                                    MediaViewActionButton(icon: "eye.fill", scrollView: $wrappedScrollView, iconColor: viewModel.isWatched ? .red : .white)
                                }
                                Text(viewModel.isWatched ? "Unwatch" : "Mark Watched")
                                    .font(.caption)
                            }
                        }.padding(.top, 15)
                        Spacer()
                    }.padding(.top, 50)

                    if(!viewModel.episodes.isEmpty) {
                        Text("Episodes")
                            .font(.headline)
                            .fontWeight(.semibold)
                        ScrollView(.horizontal) {
                            LazyHStack {
                                Spacer().frame(width: 45)
                                ForEach(viewModel.episodes, id: \.id) { episode in
                                    NavigationLink(destination: ItemView(item: episode)) {
                                        LandscapeItemElement(item: episode, inSeasonView: true)
                                    }.buttonStyle(PlainNavigationLinkButtonStyle())
                                }
                                Spacer().frame(width: 45)
                            }
                        }.padding(EdgeInsets(top: -30, leading: -90, bottom: 0, trailing: -90))
                        .frame(height: 360)
                    }
                }.padding(EdgeInsets(top: 90, leading: 90, bottom: 45, trailing: 90))
            }
        }
    }
}
