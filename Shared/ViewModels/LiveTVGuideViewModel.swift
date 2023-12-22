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
import UIKit

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
            processSelectedProgramID()
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
    @Published
    var selectedItemProgress: Double = 0.0
    @Published
    var selectedItemTimeLeft: String?
    @Published
    var selectedItemImageSource: ImageSource?
    
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
//                NSLog("program starts before guide: \(program.episodeTitle ?? program.title) start: \(dateFormatter.string(from:program.startDate!)) end \(dateFormatter.string(from:program.endDate!))")
                return totalSeconds - secondsBeforeStart
            } else {
//                NSLog("program: \(program.episodeTitle ?? program.title) start: \(dateFormatter.string(from:program.startDate!)) end \(dateFormatter.string(from:program.endDate!))")
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
                Task { @MainActor in
                    self.channels[channelId] = channel
                }
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
    
    func getProgram(programID: String) async throws -> Response<BaseItemDtoQueryResult> {
        let parameters = Paths.GetLiveTvProgramParameters(
            userID: userSession.user.id
        )
        
        let request = Paths.getLiveTvProgram(programID: programID, parameters: parameters)
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
    
    private func processSelectedProgramID() {
        guard let sId = selectedId else {
            return
        }
        Task { @MainActor in
            selectedItem = programs[sId]
            guard let channelId = programsToChannels[sId], let channel = channels[channelId], let item = selectedItem else {
                return
            }
            
            // Get Program Details
            selectedItemDescription = ""
            selectedItemImageSource = nil
            Task {
                do {
                    let programInfoResponse = try await getProgram(programID: sId)
                    if let jsonString = String(data: programInfoResponse.data, encoding: .utf8) {
                        let removeBackslash = jsonString.replacingOccurrences(of: "\\", with: "")
                        print(removeBackslash)
                        if let stringData = removeBackslash.data(using: .utf8) {
                            let decoder = JSONDecoder()
                            let programDetails = try decoder.decode(ProgramDetails.self, from: stringData)
                            selectedItemDescription = programDetails.overview
                            
                            if let imageTag = programDetails.imageTags?.primary, let itemId = programDetails.id {
                                selectedItemImageSource = portraitPosterImageSource(itemID: itemId, imageTag: imageTag)
                            }
                        }
                        
                    }
                } catch let error {
                    print("getProgram error: \(error.localizedDescription)")
                }
            }
            
            var itemInfo = channel.name ?? ""
            if let airDate = item.airDateLabel {
                itemInfo += " • \(airDate)"
            }
            if let seasonNum = item.seriesCount, let epNum = item.episodeCount {
                itemInfo += " • S\(seasonNum) E\(epNum)"
            }
            if let title = item.name, title != channel.name {
                itemInfo += " • \(title)"
            }
            if let epTitle = item.episodeTitle, epTitle != item.name {
                itemInfo += " • \(epTitle)"
            }
            if let rating = item.officialRating {
                itemInfo += " • \(rating)"
            }
            if let chNum = channel.channelNumber {
                itemInfo += " • \(chNum)"
            }
            
            if let genres = item.genres {
                selectedItemGenre = genres.reduce("") { "\($0) " + $1 }
            } else {
                selectedItemGenre = ""
            }
            selectedItemInfo = itemInfo
            
            if let startTime = item.startDate?.timeIntervalSince1970 {
                let nowSeconds = Date.now.timeIntervalSince1970
                let elapsed = nowSeconds - startTime
                let remaining = Double(item.runTimeSeconds) - elapsed
                let remainingMins = Int(remaining) % 60
                selectedItemTimeLeft = "\(remainingMins) min\(remainingMins > 1 ? "s" : "") left"
                if item.runTimeSeconds > 0 {
                    selectedItemProgress = elapsed / Double(item.runTimeSeconds)
                } else {
                    selectedItemProgress = 0
                }
            } else {
                selectedItemTimeLeft = ""
            }
        }
    }
    
    func portraitPosterImageSource(itemID: String, imageTag: String) -> ImageSource {
        let scaleWidth = UIScreen.main.scale(180)
        let client = Container.userSession.callAsFunction().client
        let imageRequestParameters = Paths.GetItemImageParameters(
            maxWidth: scaleWidth,
            tag: imageTag
        )

        let imageRequest = Paths.getItemImage(
            itemID: itemID,
            imageType: ImageType.primary.rawValue,
            parameters: imageRequestParameters
        )

        let url = client.fullURL(with: imageRequest)

        return ImageSource(url: url, blurHash: nil)
    }
}


// TODO: PR this on jellyfin-swift-sdk

import Get
import URLQueryEncoder

public extension Paths {
    /// Gets available live tv epgs.
    static func getLiveTvProgram(programID: String, parameters: GetLiveTvProgramParameters? = nil) -> Request<JellyfinAPI.BaseItemDtoQueryResult> {
        Request(path: "/LiveTv/Programs/\(programID)", method: "GET", query: parameters?.asQuery, id: "GetLiveTvPrograms")
    }

    struct GetLiveTvProgramParameters {
        public var channelIDs: [String]?
        public var userID: String?
        public var minStartDate: Date?
        public var hasAired: Bool?
        public var isAiring: Bool?
        public var maxStartDate: Date?
        public var minEndDate: Date?
        public var maxEndDate: Date?
        public var isMovie: Bool?
        public var isSeries: Bool?
        public var isNews: Bool?
        public var isKids: Bool?
        public var isSports: Bool?
        public var startIndex: Int?
        public var limit: Int?
        public var sortBy: [String]?
        public var sortOrder: [JellyfinAPI.SortOrder]?
        public var genres: [String]?
        public var genreIDs: [String]?
        public var enableImages: Bool?
        public var imageTypeLimit: Int?
        public var enableImageTypes: [JellyfinAPI.ImageType]?
        public var enableUserData: Bool?
        public var seriesTimerID: String?
        public var librarySeriesID: String?
        public var fields: [JellyfinAPI.ItemFields]?
        public var enableTotalRecordCount: Bool?

        public init(
            channelIDs: [String]? = nil,
            userID: String? = nil,
            minStartDate: Date? = nil,
            hasAired: Bool? = nil,
            isAiring: Bool? = nil,
            maxStartDate: Date? = nil,
            minEndDate: Date? = nil,
            maxEndDate: Date? = nil,
            isMovie: Bool? = nil,
            isSeries: Bool? = nil,
            isNews: Bool? = nil,
            isKids: Bool? = nil,
            isSports: Bool? = nil,
            startIndex: Int? = nil,
            limit: Int? = nil,
            sortBy: [String]? = nil,
            sortOrder: [JellyfinAPI.SortOrder]? = nil,
            genres: [String]? = nil,
            genreIDs: [String]? = nil,
            enableImages: Bool? = nil,
            imageTypeLimit: Int? = nil,
            enableImageTypes: [JellyfinAPI.ImageType]? = nil,
            enableUserData: Bool? = nil,
            seriesTimerID: String? = nil,
            librarySeriesID: String? = nil,
            fields: [JellyfinAPI.ItemFields]? = nil,
            enableTotalRecordCount: Bool? = nil
        ) {
            self.channelIDs = channelIDs
            self.userID = userID
            self.minStartDate = minStartDate
            self.hasAired = hasAired
            self.isAiring = isAiring
            self.maxStartDate = maxStartDate
            self.minEndDate = minEndDate
            self.maxEndDate = maxEndDate
            self.isMovie = isMovie
            self.isSeries = isSeries
            self.isNews = isNews
            self.isKids = isKids
            self.isSports = isSports
            self.startIndex = startIndex
            self.limit = limit
            self.sortBy = sortBy
            self.sortOrder = sortOrder
            self.genres = genres
            self.genreIDs = genreIDs
            self.enableImages = enableImages
            self.imageTypeLimit = imageTypeLimit
            self.enableImageTypes = enableImageTypes
            self.enableUserData = enableUserData
            self.seriesTimerID = seriesTimerID
            self.librarySeriesID = librarySeriesID
            self.fields = fields
            self.enableTotalRecordCount = enableTotalRecordCount
        }

        public var asQuery: [(String, String?)] {
            let encoder = URLQueryEncoder()
            encoder.encode(channelIDs, forKey: "channelIds")
            encoder.encode(userID, forKey: "userId")
            encoder.encode(minStartDate, forKey: "minStartDate")
            encoder.encode(hasAired, forKey: "hasAired")
            encoder.encode(isAiring, forKey: "isAiring")
            encoder.encode(maxStartDate, forKey: "maxStartDate")
            encoder.encode(minEndDate, forKey: "minEndDate")
            encoder.encode(maxEndDate, forKey: "maxEndDate")
            encoder.encode(isMovie, forKey: "isMovie")
            encoder.encode(isSeries, forKey: "isSeries")
            encoder.encode(isNews, forKey: "isNews")
            encoder.encode(isKids, forKey: "isKids")
            encoder.encode(isSports, forKey: "isSports")
            encoder.encode(startIndex, forKey: "startIndex")
            encoder.encode(limit, forKey: "limit")
            encoder.encode(sortBy, forKey: "sortBy")
            encoder.encode(sortOrder, forKey: "sortOrder")
            encoder.encode(genres, forKey: "genres")
            encoder.encode(genreIDs, forKey: "genreIds")
            encoder.encode(enableImages, forKey: "enableImages")
            encoder.encode(imageTypeLimit, forKey: "imageTypeLimit")
            encoder.encode(enableImageTypes, forKey: "enableImageTypes")
            encoder.encode(enableUserData, forKey: "enableUserData")
            encoder.encode(seriesTimerID, forKey: "seriesTimerId")
            encoder.encode(librarySeriesID, forKey: "librarySeriesId")
            encoder.encode(fields, forKey: "fields")
            encoder.encode(enableTotalRecordCount, forKey: "enableTotalRecordCount")
            return encoder.items
        }
    }
}

// Model used to decode getLiveTvProgram response
struct ProgramDetails: Decodable {
        let name: String?
        let serverId: String?
        let id: String?
        let etag: String?
        let dateCreated: Date?
        let canDelete: Bool?
        let canDownload: Bool?
        let sortName: String?
        let externalUrls: [String]
        let enableMediaSourceDisplay: Bool?
        let officialRating: String?
        let channelId: String?
        let channelName: String?
        let overview: String?
        let taglines: [String]
        let genres: [String]
        let runTimeTicks: Int?
        let playAccess: String?
        let channelNumber: String?
        let indexNumber: Int?
        let parentIndexNumber: Int?
        let remoteTrailers: [String]
        let providerIds: [String: String]
        let parentId: String?
        let type: String?
        let people: [String]
        let studios: [String]
        let genreItems: [GenreItem]
        let localTrailerCount: Int?
        let userData: UserData?
        let specialFeatureCount: Int?
        let displayPreferencesId: String?
        let tags: [String]
        let primaryImageAspectRatio: Double?
        let imageTags: ImageTags?
        let backdropImageTags: [String]
        let imageBlurHashes: [String: String]
        let mediaType: String?
        let endDate: Date?
        let lockedFields: [String]
        let lockData: Bool?
        let channelPrimaryImageTag: String?
        let startDate: Date?
        let isRepeat: Bool?
        let episodeTitle: String?
        let isSeries: Bool?

        private enum CodingKeys: String, CodingKey {
           case name = "Name"
           case serverId = "ServerId"
           case id = "Id"
           case etag = "Etag"
           case dateCreated = "DateCreated"
           case canDelete = "CanDelete"
           case canDownload = "CanDownload"
           case sortName = "SortName"
           case externalUrls = "ExternalUrls"
           case enableMediaSourceDisplay = "EnableMediaSourceDisplay"
           case officialRating = "OfficialRating"
           case channelId = "ChannelId"
           case channelName = "ChannelName"
           case overview = "Overview"
           case taglines = "Taglines"
           case genres = "Genres"
           case runTimeTicks = "RunTimeTicks"
           case playAccess = "PlayAccess"
           case channelNumber = "ChannelNumber"
           case indexNumber = "IndexNumber"
           case parentIndexNumber = "ParentIndexNumber"
           case remoteTrailers = "RemoteTrailers"
           case providerIds = "ProviderIds"
           case parentId = "ParentId"
           case type = "Type"
           case people = "People"
           case studios = "Studios"
           case genreItems = "GenreItems"
           case localTrailerCount = "LocalTrailerCount"
           case userData = "UserData"
           case specialFeatureCount = "SpecialFeatureCount"
           case displayPreferencesId = "DisplayPreferencesId"
           case tags = "Tags"
           case primaryImageAspectRatio = "PrimaryImageAspectRatio"
           case imageTags = "ImageTags"
           case backdropImageTags = "BackdropImageTags"
           case imageBlurHashes = "ImageBlurHashes"
           case mediaType = "MediaType"
           case endDate = "EndDate"
           case lockedFields = "LockedFields"
           case lockData = "LockData"
           case channelPrimaryImageTag = "ChannelPrimaryImageTag"
           case startDate = "StartDate"
           case isRepeat = "IsRepeat"
           case episodeTitle = "EpisodeTitle"
           case isSeries = "IsSeries"
        }

       init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)

           // Use a custom date decoding strategy with fractional seconds
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
           dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

           name = try container.decodeIfPresent(String.self, forKey: .name)
           serverId = try container.decodeIfPresent(String.self, forKey: .serverId)
           id = try container.decodeIfPresent(String.self, forKey: .id)
           etag = try container.decodeIfPresent(String.self, forKey: .etag)
           if let dateCreatedString = try container.decodeIfPresent(String.self, forKey: .dateCreated) {
               dateCreated = dateFormatter.date(from: dateCreatedString)
           } else {
               dateCreated = nil
           }
           canDelete = try container.decodeIfPresent(Bool.self, forKey: .canDelete)
           canDownload = try container.decodeIfPresent(Bool.self, forKey: .canDownload)
           sortName = try container.decodeIfPresent(String.self, forKey: .sortName)
           externalUrls = try container.decodeIfPresent([String].self, forKey: .externalUrls) ?? []
           enableMediaSourceDisplay = try container.decodeIfPresent(Bool.self, forKey: .enableMediaSourceDisplay)
           officialRating = try container.decodeIfPresent(String.self, forKey: .officialRating)
           channelId = try container.decodeIfPresent(String.self, forKey: .channelId)
           channelName = try container.decodeIfPresent(String.self, forKey: .channelName)
           overview = try container.decodeIfPresent(String.self, forKey: .overview)
           taglines = try container.decodeIfPresent([String].self, forKey: .taglines) ?? []
           genres = try container.decodeIfPresent([String].self, forKey: .genres) ?? []
           runTimeTicks = try container.decodeIfPresent(Int.self, forKey: .runTimeTicks)
           playAccess = try container.decodeIfPresent(String.self, forKey: .playAccess)
           channelNumber = try container.decodeIfPresent(String.self, forKey: .channelNumber)
           indexNumber = try container.decodeIfPresent(Int.self, forKey: .indexNumber)
           parentIndexNumber = try container.decodeIfPresent(Int.self, forKey: .parentIndexNumber)
           remoteTrailers = try container.decodeIfPresent([String].self, forKey: .remoteTrailers) ?? []
           providerIds = try container.decodeIfPresent([String: String].self, forKey: .providerIds) ?? [:]
           parentId = try container.decodeIfPresent(String.self, forKey: .parentId)
           type = try container.decodeIfPresent(String.self, forKey: .type)
           people = try container.decodeIfPresent([String].self, forKey: .people) ?? []
           studios = try container.decodeIfPresent([String].self, forKey: .studios) ?? []
           genreItems = try container.decodeIfPresent([GenreItem].self, forKey: .genreItems) ?? []
           localTrailerCount = try container.decodeIfPresent(Int.self, forKey: .localTrailerCount)
           userData = try container.decodeIfPresent(UserData.self, forKey: .userData)
           specialFeatureCount = try container.decodeIfPresent(Int.self, forKey: .specialFeatureCount)
           displayPreferencesId = try container.decodeIfPresent(String.self, forKey: .displayPreferencesId)
           tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
           primaryImageAspectRatio = try container.decodeIfPresent(Double.self, forKey: .primaryImageAspectRatio)
           imageTags = try container.decodeIfPresent(ImageTags.self, forKey: .imageTags)
           backdropImageTags = try container.decodeIfPresent([String].self, forKey: .backdropImageTags) ?? []
           imageBlurHashes = try container.decodeIfPresent([String: String].self, forKey: .imageBlurHashes) ?? [:]
           mediaType = try container.decodeIfPresent(String.self, forKey: .mediaType)
           if let endDateString = try container.decodeIfPresent(String.self, forKey: .endDate) {
               endDate = dateFormatter.date(from: endDateString)
           } else {
               endDate = nil
           }
           lockedFields = try container.decodeIfPresent([String].self, forKey: .lockedFields) ?? []
           lockData = try container.decodeIfPresent(Bool.self, forKey: .lockData)
           channelPrimaryImageTag = try container.decodeIfPresent(String.self, forKey: .channelPrimaryImageTag)
           if let startDateString = try container.decodeIfPresent(String.self, forKey: .startDate) {
               startDate = dateFormatter.date(from: startDateString)
           } else {
               startDate = nil
           }
           isRepeat = try container.decodeIfPresent(Bool.self, forKey: .isRepeat)
           episodeTitle = try container.decodeIfPresent(String.self, forKey: .episodeTitle)
           isSeries = try container.decodeIfPresent(Bool.self, forKey: .isSeries)
       }
}

struct GenreItem: Decodable {
    let name: String?
    let id: String?
}

struct UserData: Decodable {
    let playbackPositionTicks: Int?
    let playCount: Int?
    let isFavorite: Bool?
    let played: Bool?
    let key: String?

    private enum CodingKeys: String, CodingKey {
        case playbackPositionTicks = "PlaybackPositionTicks"
        case playCount = "PlayCount"
        case isFavorite = "IsFavorite"
        case played = "Played"
        case key = "Key"
    }
}

struct ImageTags: Decodable {
    let primary: String?
    
    private enum CodingKeys: String, CodingKey {
        case primary = "Primary"
    }
}
