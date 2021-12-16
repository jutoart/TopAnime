//
//  PersistenceViewModel.swift
//  TopAnime
//
//  Created by Art Huang on 2021/12/16.
//  Copyright © 2021 Art Huang. All rights reserved.
//

import Foundation

class PersistenceViewModel: ObservableObject {
    @Published var favorites: [String: AnimeModel]

    private let persistenceService: UserDefaults

    init(persistenceService: UserDefaults = .standard) {
        self.persistenceService = persistenceService
        if let favoriteData = persistenceService.object(forKey: Constant.FavoritesPersistenceKey) as? Data {
            favorites = (try? JSONDecoder().decode([String: AnimeModel].self, from: favoriteData)) ?? [:]
        } else {
            favorites = [:]
        }
    }

    func setAnimeModel(_ animeModel: AnimeModel, isFavorite: Bool) {
        if isFavorite {
            favorites[animeModel.id] = animeModel
        } else {
            guard favorites[animeModel.id] != nil else { return }
            favorites.removeValue(forKey: animeModel.id)
        }

        guard let favoriteData = try? JSONEncoder().encode(favorites) else { return }
        persistenceService.set(favoriteData, forKey: Constant.FavoritesPersistenceKey)
    }
}

// MARK: - Constants

extension PersistenceViewModel {
    private enum Constant {
        static let FavoritesPersistenceKey = "favorites"
    }
}
