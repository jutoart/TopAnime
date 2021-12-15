//
//  AnimeType.swift
//  TopAnime
//
//  Created by Art Huang on 2021/12/15.
//  Copyright © 2021 Art Huang. All rights reserved.
//

import Foundation

enum AnimeType: String, CaseIterable {
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
}

enum AnimeSubType: String, CaseIterable {
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
}
