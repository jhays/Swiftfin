import SwiftUI
import JellyfinAPI

struct EpisodeItemView: View {
    @ObservedObject var viewModel: EpisodeItemViewModel

    @State var actors: [BaseItemPerson] = [];
    @State var studio: String? = nil;
    @State var director: String? = nil;
    
    func onAppear() {
        actors = []
        director = nil
        studio = nil
        var actor_index = 0;
        viewModel.item.people?.forEach { person in
            if(person.type == "Actor") {
                if(actor_index < 4) {
                    actors.append(person)
                }
                actor_index = actor_index + 1;
            }
            if(person.type == "Director") {
                director = person.name ?? ""
            }
        }
        
        studio = viewModel.item.studios?.first?.name ?? nil
    }
    
    var body: some View {
        ZStack {
            ImageView(src: viewModel.item.getBackdropImage(maxWidth: 1920), bh: viewModel.item.getBackdropImageBlurHash())
                .opacity(0.4)
            LazyVStack(alignment: .leading) {
                Text(viewModel.item.name ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(viewModel.item.seriesName ?? "")
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                HStack {
                    if viewModel.item.productionYear != nil {
                        Text(String(viewModel.item.productionYear!)).font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    Text(viewModel.item.getItemRuntime()).font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    if viewModel.item.officialRating != nil {
                        Text(viewModel.item.officialRating!).font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .padding(EdgeInsets(top: 1, leading: 4, bottom: 1, trailing: 4))
                            .overlay(RoundedRectangle(cornerRadius: 2)
                                .stroke(Color.secondary, lineWidth: 1))
                    }
                    Spacer()
                }.padding(.top, -15)
                
                HStack(alignment: .top) {
                    VStack(alignment: .trailing) {
                        if(studio != nil) {
                            Text("STUDIO")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text(studio!)
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 40)
                        }
                        
                        if(director != nil) {
                            Text("DIRECTOR")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text(director!)
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 40)
                        }
                        
                        if(!actors.isEmpty) {
                            Text("CAST")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            ForEach(actors, id: \.id) { person in
                                Text(person.name!)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                    VStack(alignment: .leading) {
                        Text(viewModel.item.overview ?? "")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        HStack {
                            VStack {
                                Button {
                                    viewModel.updateFavoriteState()
                                } label: {
                                    MediaViewActionButton(icon: "heart.fill", iconColor: viewModel.isFavorited ? .red : .white)
                                }
                                Text(viewModel.isFavorited ? "Unfavorite" : "Favorite")
                                    .font(.caption)
                            }
                            VStack {
                                NavigationLink(destination: VideoPlayerView(item: viewModel.item)) {
                                    MediaViewActionButton(icon: "play.fill")
                                }
                                Text(viewModel.item.getItemProgressString() != "" ? "\(viewModel.item.getItemProgressString()) left" : "Play")
                                    .font(.caption)
                            }
                            VStack {
                                Button {
                                    viewModel.updateWatchState()
                                } label: {
                                    MediaViewActionButton(icon: "eye.fill", iconColor: viewModel.isWatched ? .red : .white)
                                }
                                Text(viewModel.isWatched ? "Unwatch" : "Mark Watched")
                                    .font(.caption)
                            }
                            Spacer()
                        }
                        .padding(.top, 15)
                    }
                }.padding(.top, 50)

                if(!viewModel.similarItems.isEmpty) {
                    Text("More Like This")
                        .font(.headline)
                        .fontWeight(.semibold)
                    ScrollView(.horizontal) {
                        LazyHStack {
                            Spacer().frame(width: 45)
                            ForEach(viewModel.similarItems, id: \.id) { similarItems in
                                NavigationLink(destination: ItemView(item: similarItems)) {
                                    PortraitItemElement(item: similarItems)
                                }.buttonStyle(PlainNavigationLinkButtonStyle())
                            }
                            Spacer().frame(width: 45)
                        }
                    }.padding(EdgeInsets(top: -30, leading: -90, bottom: 0, trailing: -90))
                    .frame(height: 360)
                }
                Spacer()
                Spacer()
            }.padding(EdgeInsets(top: 90, leading: 90, bottom: 0, trailing: 90))
        }.onAppear(perform: onAppear)
    }
}
