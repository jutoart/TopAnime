//
//  AnimeViewModel.swift
//  TopAnime
//
//  Created by Art Huang on 2021/12/15.
//  Copyright © 2021 Art Huang. All rights reserved.
//

import Foundation

class AnimeViewModel: ObservableObject {
    enum State {
        case empty
        case loading([AnimeModel], Int)
        case normal([AnimeModel], Int)
        case error(String)
    }
    
    enum RequestError: Error {
        case isFetchingData
    }
    
    @Published var state: State = .empty
    
    private let service: ApiService
    
    init(service: ApiService = .init()) {
        self.service = service
    }
    
    func fetchData(fromStart: Bool = false) async throws {
        
    }
}
