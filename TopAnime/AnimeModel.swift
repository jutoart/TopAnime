//
//  AnimeModel.swift
//  TopAnime
//
//  Created by Art Huang on 2021/12/15.
//  Copyright © 2021 Art Huang. All rights reserved.
//

import Foundation

struct AnimeModel: Codable, Identifiable, Equatable {
    private(set) var id = UUID().uuidString
    let rank: Int
    let title: String
    let url: URL?
    let imageUrl: URL?
    let type: String
    let startDate: String?
    let endDate: String?

    static func == (lhs: AnimeModel, rhs: AnimeModel) -> Bool {
        return lhs.id == rhs.id
    }
}

extension AnimeModel {
    init(from rawModel: AnimeRawModel.AnimeItem) {
        self.init(rank: rawModel.rank,
                  title: rawModel.title,
                  url: rawModel.url == nil ? nil : URL(string: rawModel.url!),
                  imageUrl: rawModel.imageUrl == nil ? nil : URL(string: rawModel.imageUrl!),
                  type: rawModel.type,
                  startDate: rawModel.startDate,
                  endDate: rawModel.endDate)
    }
}
