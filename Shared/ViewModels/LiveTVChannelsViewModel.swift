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

struct LiveTVChannelProgram: Hashable {
    let id = UUID()
    let channel: BaseItemDto
    let currentProgram: BaseItemDto?
    let programs: [BaseItemDto]
}

final class LiveTVChannelsViewModel: ViewModel {

    @Published
    var channels: [BaseItemDto] = []
    @Published
    var channelPrograms: [LiveTVChannelProgram] = []
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
//        startScheduleCheckTimer()
        requestItems(replaceCurrentItems: true)
    }

    deinit {
//        stopScheduleCheckTimer()
    }

    func refresh() {
        currentPage = 0
        hasNextPage = true
        channels = []
        channelPrograms = []
    }

    func requestNextPage() {
        guard hasNextPage else { return }
        currentPage += 1
        requestItems(replaceCurrentItems: false)
    }

    private func requestItems(replaceCurrentItems: Bool = false) {

        if replaceCurrentItems {
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
        let guideInfoResponse = try await getGuideInfo()
        let channelsResponse = try await getChannels()
        guard let channels = channelsResponse.value.items, !channels.isEmpty else {
            return []
        }
        let programsResponse = try await getPrograms(channelIds: channels.compactMap(\.id))
        let programs = programsResponse.value.items ?? []
        var newChannelPrograms = [LiveTVChannelProgram]()
        let now = Date()
        for channel in channels {
            let prgs = programs.filter { item in
                item.channelID == channel.id
            }

            var currentPrg: BaseItemDto?
            for prg in prgs {
                if let startDate = prg.startDate,
                   let endDate = prg.endDate,
                   now.timeIntervalSinceReferenceDate > startDate.timeIntervalSinceReferenceDate &&
                   now.timeIntervalSinceReferenceDate < endDate.timeIntervalSinceReferenceDate
                {
                    currentPrg = prg
                }
            }

            newChannelPrograms.append(LiveTVChannelProgram(channel: channel, currentProgram: currentPrg, programs: prgs))
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

    // Will revisit this next
//    func startScheduleCheckTimer() {
//        let date = Date()
//        let calendar = Calendar.current
//        var components = calendar.dateComponents([.era, .year, .month, .day, .hour, .minute], from: date)
//
//        // Run on 10th min of every hour
//        guard let minute = components.minute else { return }
//        components.second = 0
//        components.minute = minute + (10 - (minute % 10))
//
//        guard let nextMinute = calendar.date(from: components) else { return }
//
//        if let existingTimer = timer {
//            existingTimer.invalidate()
//        }
//        timer = Timer(fire: nextMinute, interval: 60 * 10, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//            self.logger.debug("LiveTVChannels schedule check...")
//            DispatchQueue.global(qos: .background).async {
//                let newChanPrgs = self.processChannelPrograms()
//                DispatchQueue.main.async {
//                    self.channelPrograms = newChanPrgs
//                }
//            }
//        }
//        if let timer = timer {
//            RunLoop.main.add(timer, forMode: .default)
//        }
//    }

    func stopScheduleCheckTimer() {
        timer?.invalidate()
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension Date {
    func addComponentsToDate(seconds sec: Int? = nil, minutes min: Int? = nil, hours hrs: Int? = nil, days d: Int? = nil) -> Date {
        var dc = DateComponents()
        if let sec = sec {
            dc.second = sec
        }
        if let min = min {
            dc.minute = min
        }
        if let hrs = hrs {
            dc.hour = hrs
        }
        if let d = d {
            dc.day = d
        }
        return Calendar.current.date(byAdding: dc, to: self)!
    }

    func midnightUTCDate() -> Date {
        var dc: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)
        dc.hour = 0
        dc.minute = 0
        dc.second = 0
        dc.nanosecond = 0
        dc.timeZone = TimeZone(secondsFromGMT: 0)
        return Calendar.current.date(from: dc)!
    }
}
