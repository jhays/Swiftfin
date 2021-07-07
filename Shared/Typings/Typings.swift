import Combine
import Foundation
import JellyfinAPI

struct LibraryFilters: Codable, Hashable {
    var filters: [ItemFilter] = []
    var sortOrder: [APISortOrder] = [.descending]
    var withGenres: [NameGuidPair] = []
    var tags: [String] = []
    var sortBy: [SortBy] = [.name]
}

public enum SortBy: String, Codable, CaseIterable {
    case premiereDate = "PremiereDate"
    case name = "SortName"
    case dateAdded = "DateCreated"
}

extension SortBy {
    var localized: String {
        switch self {
        case .premiereDate:
            return "Premiere date"
        case .name:
            return "Name"
        case .dateAdded:
            return "Date added"
        }
    }
}

extension ItemFilter {
    static var supportedTypes: [ItemFilter] {
        [.isUnplayed, isPlayed, .isFavorite, .likes]
    }

    var localized: String {
        switch self {
        case .isUnplayed:
            return "Unplayed"
        case .isPlayed:
            return "Played"
        case .isFavorite:
            return "Favorites"
        case .likes:
            return "Liked Items"
        default:
            return ""
        }
    }
}

extension APISortOrder {
    var localized: String {
        switch self {
        case .ascending:
            return "Ascending"
        case .descending:
            return "Descending"
        }
    }
}
