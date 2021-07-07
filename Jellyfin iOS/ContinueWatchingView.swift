import SwiftUI
import JellyfinAPI

struct ProgressBar: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let tl = CGPoint(x: rect.minX, y: rect.minY)
        let tr = CGPoint(x: rect.maxX, y: rect.minY)
        let br = CGPoint(x: rect.maxX, y: rect.maxY)
        let bls = CGPoint(x: rect.minX + 10, y: rect.maxY)
        let blc = CGPoint(x: rect.minX + 10, y: rect.maxY - 10)

        path.move(to: tl)
        path.addLine(to: tr)
        path.addLine(to: br)
        path.addLine(to: bls)
        path.addRelativeArc(center: blc, radius: 10,
                            startAngle: Angle.degrees(90), delta: Angle.degrees(90))

        return path
    }
}

struct ContinueWatchingView: View {
    var items: [BaseItemDto]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(items, id: \.id) { item in
                    NavigationLink(destination: LazyView { ItemView(item: item) }) {
                        VStack(alignment: .leading) {
                            ImageView(src: item.getBackdropImage(maxWidth: 320), bh: item.getBackdropImageBlurHash())
                                .frame(width: 320, height: 180)
                                .cornerRadius(10)
                                .shadow(radius: 4)
                                .overlay(
                                    Rectangle()
                                        .fill(Color(red: 172/255, green: 92/255, blue: 195/255))
                                        .mask(ProgressBar())
                                        .frame(width: CGFloat((item.userData?.playedPercentage ?? 0) * 3.2), height: 7)
                                        .padding(0), alignment: .bottomLeading
                                )
                            HStack {
                                Text("\(item.seriesName ?? item.name ?? "")")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                if item.type == "Episode" {
                                    Text("• \(item.getEpisodeLocator()) - \(item.name ?? "")")
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                        .offset(x: -1.4)
                                }
                                Spacer()
                            }.frame(width: 320, alignment: .leading)
                        }.padding(.top, 10)
                        .padding(.bottom, 5)
                    }
                }.padding(.trailing, 16)
            }.frame(height: 215)
            .padding(EdgeInsets(top: 8, leading: 20, bottom: 10, trailing: 2))
        }
    }
}
