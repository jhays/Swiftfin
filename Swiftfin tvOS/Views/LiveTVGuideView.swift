//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import CollectionView
import Foundation
import JellyfinAPI
import SwiftUI

struct LiveTVGuideConstants {
    static let cellHeight: CGFloat = 120
    static let timeCellHeight: CGFloat = 30
    static let halfHourWidth: CGFloat = 360
    static let channelCellWidth: CGFloat = 120
    static let spacing: CGFloat = 8
}

struct LiveTVGuideView: View {
    
    @StateObject
    var viewModel = LiveTVGuideViewModel()
    
    @State private var offsetY: CGFloat = 0
  
    @State private var width: CGFloat? = nil
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            VStack {
                headerView

                ScrollView(.horizontal) {
                    timelineView
                    ScrollView {
                        HStack(spacing: LiveTVGuideConstants.spacing) {
                            VStack {
                                HStack {
                                    channelsColumn
                                }
                                Spacer()
                            }
                            ScrollView(.horizontal) {
                                VStack {
                                    guideGrid
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.selectedItem?.itemTitle ?? " ")
                    .lineLimit(1)
                    .font(.largeTitle)
                    .focusable()
                
                HStack {
                    progressBar(progress: 0.3)
                        .frame(width: 180, height: 40)
                    
                    Text("27 min left")
                        .foregroundColor(Color.jellyfinPurple)
                }
                
//                Text(" • Air Date • EpNum • Name • Rating")
                Text(viewModel.selectedItemInfo ?? " ")
                Text("Program description text string.")
                Text(viewModel.selectedItemGenre ?? " ")
            }
            
            PosterHStack(type: .landscape, items: [BaseItemDto]())
        }
    }
    
    @ViewBuilder
    var timelineView: some View {
        GeometryReader { _ in
            ZStack {
                LazyHStack(alignment: .top, spacing: LiveTVGuideConstants.spacing) {
                    ForEach(viewModel.timeMarkers) { timeMarker in
                        Text(timeMarker.time)
                            .frame(width: LiveTVGuideConstants.halfHourWidth, height: LiveTVGuideConstants.timeCellHeight, alignment: .leading)
                    }
                }
                .frame(height: LiveTVGuideConstants.timeCellHeight)
                .padding(.leading, LiveTVGuideConstants.channelCellWidth)
            }
            .frame(height: LiveTVGuideConstants.timeCellHeight)
            .offset(y:-offsetY)
        }
        .frame(height: LiveTVGuideConstants.timeCellHeight)
    }
    
    @ViewBuilder
    var channelsColumn: some View {
        LazyVStack(spacing: LiveTVGuideConstants.spacing) {
            ForEach(viewModel.channelPrograms) { channelProgram in
                LiveTVChannelCell(title:  channelProgram.channel.number ?? channelProgram.channel.name ?? " ", imageSource: channelProgram.channel.imageSource(.primary, maxWidth: 100))
            }
        }
        .frame(width: LiveTVGuideConstants.channelCellWidth)
    }
    
    @ViewBuilder
    var guideGrid: some View {
        LazyVStack(spacing: LiveTVGuideConstants.spacing) {
            ForEach(viewModel.channelPrograms) { channelProgram in
                LazyHStack(spacing: LiveTVGuideConstants.spacing) {
                    ForEach (channelProgram.programs) { program in
                        LiveTVGuideCell(
                            id: program.id,
                            title: program.itemTitle,
                            startTime: program.getLiveStartTimeString(formatter: viewModel.dateFormatter),
                            endTime: program.getLiveEndTimeString(formatter: viewModel.dateFormatter),
                            width: program.cellDurationWidth,
                            selectedId: .constant(nil)
                        )
                    }
                }
                .frame(height: LiveTVGuideConstants.cellHeight)
               
            }
        }
    }
    
    @ViewBuilder
    func progressBar(progress: CGFloat) -> some View {
        VStack(alignment: .center) {
            GeometryReader { gp in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray)
                        .opacity(0.4)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 6, maxHeight: 6)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.jellyfinPurple)
                        .frame(width: CGFloat(progress * gp.size.width), height: 6)
                }
            }
            .frame(height: 6, alignment: .center)
        }
    }
}


private extension BaseItemDto {
    var cellDurationWidth: CGFloat {
        guard let runTimeTicks else {
            return LiveTVGuideConstants.halfHourWidth
        }
        let seconds = CGFloat(runTimeTicks) / 10000000
        let minutes = seconds / 60
        let halfHours = minutes / 30
        
        return halfHours * LiveTVGuideConstants.halfHourWidth
    }
    
    var itemTitle: String {
        self.episodeTitle ?? self.title
    }
}

struct LiveTVGuideCell: View{
    
    @State var id: String?
    @State var title: String
    @State var startTime: String
    @State var endTime: String
    @State var width: CGFloat
    @Binding var selectedId: String?
    @State private var backgroundColor: Color = Color.systemFill.opacity(0.1)
    @State private var borderColor: Color = Color.systemFill.opacity(0.1)
    @State private var textColor: Color = Color.primary
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack {
                HStack {
                    Text(title)
                        .foregroundColor(textColor)
                        .padding(.leading, 16)
                    Spacer()
                }
            }
            VStack {
                HStack {
                    Text(startTime)
                    Spacer()
                    Text(endTime)
                }
                .font(.footnote)
                Spacer()
            }
        }
        .frame(width: width, height: LiveTVGuideConstants.cellHeight)
        .background(backgroundColor)
        .cornerRadius(8)
        .focusable(true)
        .focused($isFocused)
        .onChange(of: isFocused) { newValue in
            withAnimation(Animation.linear(duration: 0.2)) {
                backgroundColor = newValue ? Color.systemFill.opacity(0.5) : Color.systemFill.opacity(0.1)
                textColor = newValue ? Color.tertiarySystemFill : Color.primary
            }
            borderColor = newValue ? Color.jellyfinPurple : .clear
            if newValue {
                selectedId = id
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 1).foregroundColor(borderColor))
    }
}

struct LiveTVChannelCell: View{
    
    @State var title: String
    @State var imageSource: ImageSource
    @State private var backgroundColor: Color = Color.systemFill.opacity(0.1)
    @State private var borderColor: Color = Color.systemFill.opacity(0.1)
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            Text(title)
                .foregroundColor(Color.jellyfinPurple)
                .font(Font.caption)
            
            ImageView(imageSource)
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, alignment: .center)
                .padding(0)
        }
        .frame(width: LiveTVGuideConstants.channelCellWidth, height: LiveTVGuideConstants.cellHeight)
        .background(backgroundColor)
        .cornerRadius(8)
        .focusable(true)
        .focused($isFocused)
        .onChange(of: isFocused) { newValue in
            withAnimation(Animation.linear(duration: 0.2)) {
                backgroundColor = newValue ? Color.systemFill.opacity(0.5) : Color.systemFill.opacity(0.1)
            }
            borderColor = newValue ? Color.jellyfinPurple : .clear
        }
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 1).foregroundColor(borderColor))
    }
}
