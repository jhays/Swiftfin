import SwiftUI

struct MovieItemView: View {
    @StateObject var viewModel: MovieItemViewModel
    @State private var orientation = UIDeviceOrientation.unknown
    @Environment(\.horizontalSizeClass)
    var hSizeClass
    @Environment(\.verticalSizeClass)
    var vSizeClass
    @EnvironmentObject
    private var playbackInfo: VideoPlayerItem

    var portraitHeaderView: some View {
        ImageView(src: viewModel.item.getBackdropImage(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 622 : Int(UIScreen.main.bounds.width)),
            bh: viewModel.item.getBackdropImageBlurHash())
            .opacity(0.4)
            .blur(radius: 2.0)
    }

    var portraitHeaderOverlayView: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .bottom, spacing: 12) {
                ImageView(src: viewModel.item.getPrimaryImage(maxWidth: 120))
                    .frame(width: 120, height: 180)
                    .cornerRadius(10)
                VStack(alignment: .leading) {
                    Spacer()
                    Text(viewModel.item.name ?? "").font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .offset(y: 5)
                    HStack {
                        if viewModel.item.productionYear != nil {
                            Text(String(viewModel.item.productionYear ?? 0)).font(.subheadline)
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
                    }
                    .padding(.top, 1)
                }
                .padding(.bottom, UIDevice.current.userInterfaceIdiom == .pad ? 98 : 30)
            }
            HStack {
                // Play button
                Button {
                    self.playbackInfo.itemToPlay = viewModel.item
                    self.playbackInfo.shouldShowPlayer = true
                } label: {
                    HStack {
                        Text(viewModel.item.getItemProgressString() == "" ? "Play" : viewModel.item.getItemProgressString())
                            .foregroundColor(Color.white).font(.callout).fontWeight(.semibold)
                        Image(systemName: "play.fill").foregroundColor(Color.white).font(.system(size: 20))
                    }
                    .frame(width: 120, height: 35)
                    .background(Color(red: 172 / 255, green: 92 / 255, blue: 195 / 255))
                    .cornerRadius(10)
                }.buttonStyle(PlainButtonStyle())
                    .frame(width: 120, height: 35)
                Spacer()
                HStack {
                    Button {
                        viewModel.updateFavoriteState()
                    } label: {
                        if viewModel.isFavorited {
                            Image(systemName: "heart.fill").foregroundColor(Color(UIColor.systemRed))
                                .font(.system(size: 20))
                        } else {
                            Image(systemName: "heart").foregroundColor(Color.primary)
                                .font(.system(size: 20))
                        }
                    }
                    .disabled(viewModel.isLoading)
                    Button {
                        viewModel.updateWatchState()
                    } label: {
                        if viewModel.isWatched {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(Color.primary)
                                .font(.system(size: 20))
                        } else {
                            Image(systemName: "checkmark.circle").foregroundColor(Color.primary)
                                .font(.system(size: 20))
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }.padding(.top, 8)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .pad ? -189 : -64)
    }

    var body: some View {
        VStack(alignment: .leading) {
            if hSizeClass == .compact && vSizeClass == .regular {
                ParallaxHeaderScrollView(header: portraitHeaderView, staticOverlayView: portraitHeaderOverlayView,
                                         overlayAlignment: .bottomLeading,
                                         headerHeight: UIDevice.current.userInterfaceIdiom == .pad ? 350 : UIScreen.main.bounds
                                             .width * 0.5625) {
                    VStack(alignment: .leading) {
                        Spacer()
                            .frame(height: UIDevice.current.userInterfaceIdiom == .pad ? 135 : 40)
                            .padding(.bottom, UIDevice.current.userInterfaceIdiom == .pad ? 54 : 24)
                        if !(viewModel.item.taglines ?? []).isEmpty {
                            Text(viewModel.item.taglines!.first!).font(.body).italic().padding(.top, 7)
                                .fixedSize(horizontal: false, vertical: true).padding(.leading, 16)
                                .padding(.trailing, 16)
                        }
                        Text(viewModel.item.overview ?? "").font(.footnote).padding(.top, 3)
                            .fixedSize(horizontal: false, vertical: true).padding(.bottom, 3).padding(.leading, 16)
                            .padding(.trailing, 16)
                        if !(viewModel.item.genreItems ?? []).isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    Text("Genres:").font(.callout).fontWeight(.semibold)
                                    ForEach(viewModel.item.genreItems!, id: \.id) { genre in
                                        NavigationLink(destination: LazyView {
                                            LibraryView(viewModel: .init(genre: genre), title: genre.name ?? "")
                                        }) {
                                            Text(genre.name ?? "").font(.footnote)
                                        }
                                    }
                                }.padding(.leading, 16).padding(.trailing, 16)
                            }
                        }
                        if !(viewModel.item.people ?? []).isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                VStack {
                                    Spacer().frame(height: 8)
                                    HStack {
                                        Spacer().frame(width: 16)
                                        ForEach(viewModel.item.people!, id: \.self) { person in
                                            if person.type! == "Actor" {
                                                NavigationLink(destination: LazyView {
                                                    LibraryView(viewModel: .init(person: person), title: person.name ?? "")
                                                }) {
                                                    VStack {
                                                        ImageView(src: person
                                                            .getImage(baseURL: ServerEnvironment.current.server.baseURI!, maxWidth: 100),
                                                            bh: person.getBlurHash())
                                                            .frame(width: 100, height: 100)
                                                            .cornerRadius(10)
                                                        Text(person.name ?? "").font(.footnote).fontWeight(.regular).lineLimit(1)
                                                            .frame(width: 100).foregroundColor(Color.primary)
                                                        if person.role != "" {
                                                            Text(person.role!).font(.caption).fontWeight(.medium).lineLimit(1)
                                                                .foregroundColor(Color.secondary).frame(width: 100)
                                                        }
                                                    }
                                                }
                                                Spacer().frame(width: 10)
                                            }
                                        }
                                        Spacer().frame(width: 16)
                                    }
                                }
                            }.padding(.top, -3)
                        }
                        if !(viewModel.item.studios ?? []).isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    Text("Studios:").font(.callout).fontWeight(.semibold)
                                    ForEach(viewModel.item.studios!, id: \.id) { studio in
                                        NavigationLink(destination: LazyView {

                                                    LibraryView(viewModel: .init(studio: studio), title: studio.name ?? "")
                                        }) {
                                            Text(studio.name ?? "").font(.footnote)
                                        }
                                    }
                                }.padding(.leading, 16).padding(.trailing, 16)
                            }
                        }
                        Spacer().frame(height: 3)
                    }
                }
            } else {
                GeometryReader { geometry in
                    ZStack {
                        ImageView(src: viewModel.item.getBackdropImage(maxWidth: 200),
                                  bh: viewModel.item.getBackdropImageBlurHash())
                            .opacity(0.3)
                            .frame(width: geometry.size.width + geometry.safeAreaInsets.leading + geometry.safeAreaInsets.trailing,
                                   height: geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom)
                            .edgesIgnoringSafeArea(.all)
                            .blur(radius: 4)
                        HStack {
                            VStack {
                                ImageView(src: viewModel.item.getPrimaryImage(maxWidth: 120),
                                          bh: viewModel.item.getPrimaryImageBlurHash())
                                    .frame(width: 120, height: 180)
                                    .cornerRadius(10)
                                Spacer().frame(height: 15)
                                Button {
                                    self.playbackInfo.itemToPlay = viewModel.item
                                    self.playbackInfo.shouldShowPlayer = true
                                } label: {
                                    HStack {
                                        Text(viewModel.item.getItemProgressString() == "" ? "Play" : "\(viewModel.item.getItemProgressString()) left")
                                            .foregroundColor(Color.white).font(.callout).fontWeight(.semibold)
                                        Image(systemName: "play.fill").foregroundColor(Color.white).font(.system(size: 20))
                                    }
                                    .frame(width: 120, height: 35)
                                    .background(Color(red: 172 / 255, green: 92 / 255, blue: 195 / 255))
                                    .cornerRadius(10)
                                }.buttonStyle(PlainButtonStyle())
                                    .frame(width: 120, height: 35)
                                Spacer()
                            }
                            ScrollView {
                                VStack(alignment: .leading) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(viewModel.item.name ?? "").font(.headline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .offset(x: 14, y: 0)
                                            Spacer().frame(height: 1)
                                            HStack {
                                                if viewModel.item.productionYear != nil {
                                                    Text(String(viewModel.item.productionYear ?? 0)).font(.subheadline)
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
                                                if viewModel.item.communityRating != nil {
                                                    HStack {
                                                        Image(systemName: "star").foregroundColor(.secondary)
                                                        Text(String(viewModel.item.communityRating!)).font(.subheadline)
                                                            .fontWeight(.semibold)
                                                            .foregroundColor(.secondary)
                                                            .lineLimit(1)
                                                            .offset(x: -7, y: 0.7)
                                                    }
                                                }
                                                Spacer()
                                            }.frame(maxWidth: .infinity, alignment: .leading)
                                                .offset(x: 14)
                                            .padding(.top, 1)
                                        }.frame(maxWidth: .infinity, alignment: .leading)
                                        Spacer()
                                        HStack {
                                            Button {
                                                viewModel.updateFavoriteState()
                                            } label: {
                                                if viewModel.isFavorited {
                                                    Image(systemName: "heart.fill").foregroundColor(Color(UIColor.systemRed))
                                                        .font(.system(size: 20))
                                                } else {
                                                    Image(systemName: "heart").foregroundColor(Color.primary)
                                                        .font(.system(size: 20))
                                                }
                                            }
                                            .disabled(viewModel.isLoading)
                                            Button {
                                                viewModel.updateWatchState()
                                            } label: {
                                                if viewModel.isWatched {
                                                    Image(systemName: "checkmark.circle.fill").foregroundColor(Color.primary)
                                                        .font(.system(size: 20))
                                                } else {
                                                    Image(systemName: "checkmark.circle").foregroundColor(Color.primary)
                                                        .font(.system(size: 20))
                                                }
                                            }
                                            .disabled(viewModel.isLoading)
                                        }
                                    }.padding(.trailing, UIDevice.current.userInterfaceIdiom == .pad ? 16 : 55)
                                    if !(viewModel.item.taglines ?? []).isEmpty {
                                        Text(viewModel.item.taglines!.first!).font(.body).italic().padding(.top, 3)
                                            .fixedSize(horizontal: false, vertical: true).padding(.leading, 16)
                                            .padding(.trailing, UIDevice.current.userInterfaceIdiom == .pad ? 16 : 55)
                                    }
                                    Text(viewModel.item.overview ?? "").font(.footnote).padding(.top, 3)
                                        .fixedSize(horizontal: false, vertical: true).padding(.bottom, 3).padding(.leading, 16)
                                        .padding(.trailing, UIDevice.current.userInterfaceIdiom == .pad ? 16 : 55)
                                    if !(viewModel.item.genreItems ?? []).isEmpty {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack {
                                                Text("Genres:").font(.callout).fontWeight(.semibold)
                                                ForEach(viewModel.item.genreItems!, id: \.id) { genre in
                                                    NavigationLink(destination: LazyView {
                                                        LibraryView(viewModel: .init(genre: genre), title: genre.name ?? "")
                                                    }) {
                                                        Text(genre.name ?? "").font(.footnote)
                                                    }
                                                }
                                            }
                                            .padding(.leading, 16)
                                            .padding(.trailing, UIDevice.current.userInterfaceIdiom == .pad ? 16 : 55)
                                        }
                                    }
                                    if !(viewModel.item.people ?? []).isEmpty {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            VStack {
                                                Spacer().frame(height: 8)
                                                HStack {
                                                    Spacer().frame(width: 16)
                                                    ForEach(viewModel.item.people!, id: \.self) { person in
                                                        if person.type! == "Actor" {
                                                            NavigationLink(destination: LazyView {
                                                                LibraryView(viewModel: .init(person: person), title: person.name ?? "")
                                                            }) {
                                                                VStack {
                                                                    ImageView(src: person
                                                                        .getImage(baseURL: ServerEnvironment.current.server.baseURI!,
                                                                                  maxWidth: 100),
                                                                        bh: person.getBlurHash())
                                                                        .frame(width: 100, height: 100)
                                                                        .cornerRadius(10)
                                                                    Text(person.name ?? "").font(.footnote).fontWeight(.regular)
                                                                        .lineLimit(1)
                                                                        .frame(width: 100).foregroundColor(Color.primary)
                                                                    if person.role != "" {
                                                                        Text(person.role!).font(.caption).fontWeight(.medium).lineLimit(1)
                                                                            .foregroundColor(Color.secondary).frame(width: 100)
                                                                    }
                                                                }
                                                            }
                                                            Spacer().frame(width: 10)
                                                        }
                                                    }
                                                    Spacer().frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 16 : 55)
                                                }
                                            }
                                        }.padding(.top, -3)
                                    }
                                    if !(viewModel.item.studios ?? []).isEmpty {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack {
                                                Text("Studios:").font(.callout).fontWeight(.semibold)
                                                ForEach(viewModel.item.studios!, id: \.id) { studio in
                                                    NavigationLink(destination: LazyView {
                                                        LibraryView(viewModel: .init(studio: studio), title: studio.name ?? "")
                                                    }) {
                                                        Text(studio.name ?? "").font(.footnote)
                                                    }
                                                }
                                            }
                                            .padding(.leading, 16)
                                            .padding(.trailing, UIDevice.current.userInterfaceIdiom == .pad ? 16 : 55)
                                        }
                                    }
                                    Spacer().frame(height: 105)
                                }.frame(maxHeight: .infinity)
                            }
                        }.padding(.top, 16).padding(.leading, UIDevice.current.userInterfaceIdiom == .pad ? 16 : 55)
                            .edgesIgnoringSafeArea(.leading)
                    }
                }
            }
        }
        .onRotate {
            orientation = $0
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.item.name ?? "")
    }
}
