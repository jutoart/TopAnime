//
//  AnimeViewModel.swift
//  TopAnime
//
//  Created by Art Huang on 2021/12/15.
//  Copyright © 2021 Art Huang. All rights reserved.
//

import Foundation

class AnimeViewModel: ObservableObject {
    enum State: Equatable {
        case empty
        case loading([AnimeModel], Int)
        case normal([AnimeModel], Int)
        case error(String)
    }

    enum RequestError: Error {
        case isFetchingData
    }

    var type: AnimeType = .anime
    var subType: AnimeSubType = .airing

    @Published private(set) var state: State = .empty

    private let service: ApiService
    private var fetchId: String?
    private var isEndOFData = false

    init(service: ApiService = .init()) {
        self.service = service
    }

    @MainActor func updateState(_ state: State) {
        self.state = state
    }

    func fetchData(fromStart: Bool = false) async throws {
        switch state {
        case .empty, .error:
            await fetchDataFromStart()
        case .loading:
            if fromStart {
                await fetchDataFromStart()
            } else {
                throw RequestError.isFetchingData
            }
        case let .normal(currentAnimeModels, currentPage):
            if fromStart {
                await fetchDataFromStart()
            } else {
                // load more case
                guard !isEndOFData else { return }

                let nextPage = currentPage + 1
                await updateState(.loading(currentAnimeModels, nextPage))

                let currentFetchId = UUID().uuidString
                fetchId = currentFetchId

                do {
                    let animeModels = try await service.fetchTopAnime(type: type, subType: subType, page: nextPage)
                    guard currentFetchId == fetchId else { return }
                    await updateState(.normal(currentAnimeModels + animeModels, nextPage))
                } catch {
                    // cannot load more anymore
                    guard currentFetchId == fetchId else { return }
                    await updateState(.normal(currentAnimeModels, currentPage))
                    isEndOFData = true
                }
            }
        }
    }

    private func fetchDataFromStart() async {
        await updateState(.loading([], Constant.PageStart))

        let currentFetchId = UUID().uuidString
        fetchId = currentFetchId
        isEndOFData = false

        do {
            let animeModels = try await service.fetchTopAnime(type: type, subType: subType, page: Constant.PageStart)
            guard currentFetchId == fetchId else { return }
            await updateState(.normal(animeModels, Constant.PageStart))
        } catch {
            guard currentFetchId == fetchId else { return }
            await updateState(.error(error.localizedDescription))
        }
    }
}

// MARK: - Constants

extension AnimeViewModel {
    private enum Constant {
        static let PageStart = 1
    }
}
