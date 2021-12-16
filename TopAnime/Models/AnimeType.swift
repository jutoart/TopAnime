//
//  AnimeType.swift
//  TopAnime
//
//  Created by Art Huang on 2021/12/15.
//  Copyright © 2021 Art Huang. All rights reserved.
//

import Foundation

enum AnimeType: String, CaseIterable, CustomStringConvertible {
    case anime
    case manga

    var validSubTypes: [AnimeSubType] {
        switch self {
        case .anime:
            return [.airing, .upcoming, .tv, .movie, .ova, .special, .bypopularity, .favorite]
        case .manga:
            return [.manga, .novels, .oneshots, .doujin, .manhwa, .manhua, .bypopularity, .favorite]
        }
    }

    var description: String {
        switch self {
        case .anime: return "Anime"
        case .manga: return "Manga"
        }
    }
}

enum AnimeSubType: String, CustomStringConvertible {
    case airing
    case upcoming
    case tv
    case movie
    case ova
    case special
    case manga
    case novels
    case oneshots
    case doujin
    case manhwa
    case manhua
    case bypopularity
    case favorite

    var description: String {
        switch self {
        case .airing: return "Airing"
        case .upcoming: return "Upcoming"
        case .tv: return "TV"
        case .movie: return "Movie"
        case .ova: return "OVA"
        case .special: return "Special"
        case .manga: return "Manga"
        case .novels: return "Novels"
        case .oneshots: return "Oneshots"
        case .doujin: return "Doujin"
        case .manhwa: return "Manhwa"
        case .manhua: return "Manhua"
        case .bypopularity: return "ByPopularity"
        case .favorite: return "Favorite"
        }
    }
}
