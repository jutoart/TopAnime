//
//  ApiService.swift
//  TopAnime
//
//  Created by Curea Liu on 2021/12/14.
//  Copyright © 2021 Art Huang. All rights reserved.
//

import Foundation

enum AnimeType: CaseIterable {
    case anime
    case manga
}

enum AnimeSubType: CaseIterable {
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

class ApiService {
    func fetchTopAnime(type: AnimeType, subType: AnimeSubType) async throws -> AnimeRawModel {
        .init(requestHash: "", top: [])
    }
}

// MARK: - Constants

extension ApiService {
    enum SubTypeMap {
        static let Anime: [AnimeSubType] = [.airing, .upcoming, .tv, .movie, .ova, .special, .bypopularity, .favorite]
        static let Manga: [AnimeSubType] = [.manga, .novels, .oneshots, .doujin, .manhwa, .manhua, .bypopularity, .favorite]
    }
}
