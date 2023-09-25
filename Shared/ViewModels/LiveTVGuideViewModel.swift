//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import Factory
import Foundation
import Get
import JellyfinAPI
	
struct TimeMarker: Identifiable {
    var id: Int
    let time: String
}

enum GuideCellItem {
    case timeCell(String)
    case channelCell(LiveTVChannelProgram)
    case programCell(BaseItemDto)
}

final class LiveTVGuideViewModel: ViewModel {
    
    @Published
    var channels: [String: BaseItemDto] = [:]
    @Published
    var programs: [String: BaseItemDto] = [:]
    @Published
    var channelPrograms: [LiveTVChannelProgram] = []
    @Published
    var timeMarkers: [TimeMarker] = []
    @Published
    var guideItems: [GuideCellItem] = []
    @Published
    var selectedId: String? {
        didSet {
            if let sId = selectedId {
                Task {
                    selectedItem = programs[sId]
                    guard let channelId = programsToChannels[sId], let channel = channels[channelId] else {
                        return
                    }
                    selectedItemInfo = "\(channel.name ?? channel.title) • Air Date • EpNum • Name • Rating "
                    if let genres = channel.genres {
                        selectedItemGenre = genres.reduce("") { "\($0) " + $1 }
                    }
                }
            }
        }
    }
    @Published
    var selectedItem: BaseItemDto?
    @Published
    var selectedItemInfo: String?
    @Published
    var selectedItemDescription: String?
    @Published
    var selectedItemGenre: String?
    
    var programsToChannels: [String: String] = [:]
    
    private var guideStartTime: Date = Date()
    
    public var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "h:mm"
        return df
    }()
    
    private var timer: Timer?
    
    var currentPage = 0
    var hasNextPage = true
    private let pageSize = 100
    
    var timeFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "h:mm"
        return df
    }
    
    override init() {
        super.init()
        self.timeMarkers = generateTimeMarkers()
        requestItems(replaceCurrentItems: true)
        
    }
    
    deinit {
        stopScheduleCheckTimer()
    }
    
    public func cellDurationWidth(program: BaseItemDto) -> Double {
        guard let runTimeTicks = program.runTimeTicks, let startDate = program.startDate else {
            return LiveTVGuideConstants.halfHourWidth
        }
        
        let seconds: Double = {
            let totalSeconds = Double(runTimeTicks) / 10000000
            if startDate < guideStartTime {
                let secondsBeforeStart = guideStartTime.timeIntervalSince1970 - startDate.timeIntervalSince1970
                NSLog("program starts before guide: \(program.episodeTitle ?? program.title) start: \(dateFormatter.string(from:program.startDate!)) end \(dateFormatter.string(from:program.endDate!))")
                return totalSeconds - secondsBeforeStart
            } else {
                NSLog("program: \(program.episodeTitle ?? program.title) start: \(dateFormatter.string(from:program.startDate!)) end \(dateFormatter.string(from:program.endDate!))")
                return totalSeconds
            }
        }()
        
        
        let minutes = seconds / 60
        let halfHours = minutes / 30
        return max(0, halfHours * LiveTVGuideConstants.halfHourWidth)
    }
    
    func refresh() {
        currentPage = 0
        hasNextPage = true
        channels = [:]
        programs = [:]
        channelPrograms = []
    }
    
    func requestNextPage() {
        guard hasNextPage else { return }
        
        currentPage += 1
        requestItems(replaceCurrentItems: false)
    }
    
    private func requestItems(replaceCurrentItems: Bool = false) {
        if replaceCurrentItems {
            // Only set isLoading on a replace / full load
            // Otherwise fetching next page will reset the scroll position
            // as the CollectionView is removed and redrawn after loading state is toggled
            isLoading = true
            self.channels = [:]
            self.programs = [:]
            self.channelPrograms = []
        }
        
        Task {
            let newChannelPrograms = try await getChannelPrograms()
            
            await MainActor.run {
                self.isLoading = false
                self.channelPrograms.append(contentsOf: newChannelPrograms)
            }
        }
    }
    
    private func getChannelPrograms() async throws -> [LiveTVChannelProgram] {
        let _ = try await getGuideInfo()
        let channelsResponse = try await getChannels()
        guard let newChannels = channelsResponse.value.items, !newChannels.isEmpty else {
            return []
        }
        let programsResponse = try await getPrograms(channelIds: newChannels.compactMap(\.id))
        let fetchedPrograms = programsResponse.value.items ?? []
        await MainActor.run {
            for program in fetchedPrograms {
                if let programId = program.id {
                    self.programs[programId] = program
                }
            }
        }
        var newChannelPrograms = [LiveTVChannelProgram]()
        let now = Date()
        for channel in newChannels {
            if let channelId = channel.id {
                self.channels[channelId] = channel
            }
            let prgs = programs.filter { item in
                guard let endTime = item.value.endDate else { return false }
                return item.value.channelID == channel.id && !(endTime < guideStartTime)
            }
            
            var currentPrg: BaseItemDto?
            for prg in prgs {
                if let programId = prg.value.id, let channelId = channel.id {
                    programsToChannels[programId] = channelId
                }
                if let startDate = prg.value.startDate,
                   let endDate = prg.value.endDate,
                   now.timeIntervalSinceReferenceDate > startDate.timeIntervalSinceReferenceDate &&
                    now.timeIntervalSinceReferenceDate < endDate.timeIntervalSinceReferenceDate
                {
                    currentPrg = prg.value
                }
            }
            
            let sortedPrograms = Array(prgs.values).sorted { leftItem, rightItem in
                return (leftItem.startDate ?? Date()) < (rightItem.startDate ?? Date())
            }
//            if let firstPrg = sortedPrograms.first {
//                var smallPrgs = [firstPrg]
//                if sortedPrograms.count >= 2 {
//                    smallPrgs.append(sortedPrograms[1])
//                }
//                if sortedPrograms.count >= 3 {
//                    smallPrgs.append(sortedPrograms[2])
//                }
//
//                newChannelPrograms.append(LiveTVChannelProgram(channel: channel, currentProgram: currentPrg, programs: smallPrgs))
//            }
            newChannelPrograms.append(LiveTVChannelProgram(channel: channel, currentProgram: currentPrg, programs: sortedPrograms))
        }
        
        return newChannelPrograms
    }
    
    private func getGuideInfo() async throws -> Response<GuideInfo> {
        let request = Paths.getGuideInfo
        return try await userSession.client.send(request)
    }
    
    func getChannels() async throws -> Response<BaseItemDtoQueryResult> {
        let parameters = Paths.GetLiveTvChannelsParameters(
            userID: userSession.user.id,
            startIndex: currentPage * pageSize,
            limit: pageSize,
            enableImageTypes: [.primary],
            fields: ItemFields.minimumCases,
            enableUserData: false,
            enableFavoriteSorting: true
        )
        
        let request = Paths.getLiveTvChannels(parameters: parameters)
        return try await userSession.client.send(request)
    }
    
    private func getPrograms(channelIds: [String]) async throws -> Response<BaseItemDtoQueryResult> {
        let minEndDate = Date.now.addComponentsToDate(hours: -1)
        let maxStartDate = minEndDate.addComponentsToDate(hours: 6)
        
        let parameters = Paths.GetLiveTvProgramsParameters(
            channelIDs: channelIds,
            userID: userSession.user.id,
            maxStartDate: maxStartDate,
            minEndDate: minEndDate,
            sortBy: ["StartDate"]
        )
        
        let request = Paths.getLiveTvPrograms(parameters: parameters)
        return try await userSession.client.send(request)
    }
    
    func startScheduleCheckTimer() {
        let date = Date()
        let calendar = Calendar.current
        var components = calendar.dateComponents([.era, .year, .month, .day, .hour, .minute], from: date)
        
        // Run every minute
        guard let minute = components.minute else { return }
        components.second = 0
        components.minute = minute + (1 - (minute % 1))
        
        guard let nextMinute = calendar.date(from: components) else { return }
        
        if let existingTimer = timer {
            existingTimer.invalidate()
        }
        timer = Timer(fire: nextMinute, interval: 60, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.logger.debug("LiveTVChannels schedule check...")
            
            Task {
                await MainActor.run {
                    let channelProgramsCopy = self.channelPrograms
                    var refreshedChannelPrograms: [LiveTVChannelProgram] = []
                    for channelProgram in channelProgramsCopy {
                        var currentPrg: BaseItemDto?
                        let now = Date()
                        for prg in channelProgram.programs {
                            if let startDate = prg.startDate,
                               let endDate = prg.endDate,
                               now.timeIntervalSinceReferenceDate > startDate.timeIntervalSinceReferenceDate &&
                                now.timeIntervalSinceReferenceDate < endDate.timeIntervalSinceReferenceDate
                            {
                                currentPrg = prg
                            }
                        }
                        
                        refreshedChannelPrograms
                            .append(LiveTVChannelProgram(
                                channel: channelProgram.channel,
                                currentProgram: currentPrg,
                                programs: channelProgram.programs
                            ))
                    }
                    self.channelPrograms = refreshedChannelPrograms
                }
            }
        }
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .default)
        }
    }
    
    func stopScheduleCheckTimer() {
        timer?.invalidate()
    }
    
    private func generateTimeMarkers() -> [TimeMarker] {
        let calendar = Calendar.current
        let currentDate = Date()
        let guideEndDate = currentDate.addComponentsToDate(days: 1)
        
        // Find the previous hour
        let previousHourDate = calendar.date(byAdding: .hour, value: -1, to: currentDate) ?? currentDate
        
        // Calculate the start time (previous half-hour rounded down to nearest 30 minutes)
        let startMinute = calendar.component(.minute, from: previousHourDate)
        let startMinuteRounded = (startMinute / 30) * 30
        
        let startTime: Date = {
            if startMinute >= 30 {
                // start on previous half hour
                return calendar.date(bySettingHour: calendar.component(.hour, from: currentDate), minute: startMinuteRounded, second: 0, of: currentDate) ?? currentDate
            } else {
                // start on previous hour
                return calendar.date(bySettingHour: calendar.component(.hour, from: currentDate), minute: 0, second: 0, of: currentDate) ?? currentDate
            }
        }()
        guideStartTime = startTime
        var timeStamps: [TimeMarker] = []
        var currentTime = startTime
        var index = 0
        while currentTime <= guideEndDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "H:mm"
            let timeStampString = dateFormatter.string(from: currentTime)
            timeStamps.append(TimeMarker(id: index, time: timeStampString))
            index += 1
            currentTime = calendar.date(byAdding: .minute, value: 30, to: currentTime) ?? Date()
        }
        
        return timeStamps
    }
}
