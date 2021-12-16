//
//  AnimeRawModel.swift
//  TopAnime
//
//  Created by Art Huang on 2021/12/15.
//  Copyright © 2021 Art Huang. All rights reserved.
//

import Foundation

struct AnimeRawModel: Codable {
    struct AnimeItem: Codable {
        let malId: Int
        let rank: Int
        let title: String
        let url: String?
        let imageUrl: String?
        let type: String
        let startDate: String?
        let endDate: String?
    }

    let requestHash: String
    let top: [AnimeItem]
}
