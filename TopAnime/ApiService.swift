//
//  ApiService.swift
//  TopAnime
//
//  Created by Art Huang on 2021/12/14.
//  Copyright © 2021 Art Huang. All rights reserved.
//

import Foundation

enum AnimeType: String, CaseIterable {
    case anime
    case manga
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

enum ApiServiceError: Error {
    case configurationError
    case apiError
    case invalidData
}

class ApiService {
    private let serviceProvider: ApiServiceProvider
    
    init(serviceProvider: ApiServiceProvider = URLSession.shared) {
        self.serviceProvider = serviceProvider
    }
    
    func fetchTopAnime(type: AnimeType, subType: AnimeSubType, page: Int) async throws -> AnimeRawModel {
        // make sure sub type is valid
        switch type {
        case .anime:
            guard Constant.SubTypeMap.Anime.contains(subType) || Constant.SubTypeMap.Both.contains(subType) else {
                throw ApiServiceError.configurationError
            }
        case .manga:
            guard Constant.SubTypeMap.Manga.contains(subType) || Constant.SubTypeMap.Both.contains(subType) else {
                throw ApiServiceError.configurationError
            }
        }
        
        // generate URL
        let path = String(format: Constant.PathFormat, type.rawValue, page, subType.rawValue)
        
        guard let url = URL(string: Constant.Host + path) else {
            throw ApiServiceError.configurationError
        }
        
        // retrieve data
        let data: Data
        do {
            (data, _) = try await serviceProvider.data(from: url, delegate: nil)
        } catch {
            throw ApiServiceError.apiError
        }
        
        // decode data
        do {
            return try Constant.JsonDecoder.decode(AnimeRawModel.self, from: data)
        } catch let error {
            print(error)
            throw ApiServiceError.invalidData
        }
    }
}

// MARK: - Constants

extension ApiService {
    private enum Constant {
        static let Host = "https://api.jikan.moe"
        static let PathFormat = "/v3/top/%@/%d/%@"
        static let JsonDecoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return decoder
        }()
        
        enum SubTypeMap {
            static let Anime: [AnimeSubType] = [.airing, .upcoming, .tv, .movie, .ova, .special]
            static let Manga: [AnimeSubType] = [.manga, .novels, .oneshots, .doujin, .manhwa, .manhua]
            static let Both: [AnimeSubType] = [.bypopularity, .favorite]
        }
    }
}
