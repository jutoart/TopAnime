//
//  ApiService.swift
//  TopAnime
//
//  Created by Art Huang on 2021/12/14.
//  Copyright © 2021 Art Huang. All rights reserved.
//

import Foundation

enum ApiServiceError: Error {
    case configurationError
    case apiError
    case invalidData
}

extension ApiServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .configurationError: return "Anime sub type is not matched with anime type"
        case .apiError: return "Something wrong"
        case .invalidData: return "Response data is invalid"
        }
    }
}

class ApiService {
    private let serviceProvider: ApiServiceProvider
    
    init(serviceProvider: ApiServiceProvider = URLSession.shared) {
        self.serviceProvider = serviceProvider
    }
    
    func fetchTopAnime(type: AnimeType, subType: AnimeSubType, page: Int) async throws -> [AnimeModel] {
        // make sure sub type is valid
        guard type.validSubTypes.contains(subType) else {
            throw ApiServiceError.configurationError
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
            let animeRawModel = try Constant.JsonDecoder.decode(AnimeRawModel.self, from: data)
            return animeRawModel.top.map { AnimeModel(from: $0) }
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
    }
}
