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

    var type: AnimeType = .anime {
        didSet {
            Task {
                try? await fetchData(fromStart: true)
            }
        }
    }

    var subType: AnimeSubType = .airing {
        didSet {
            Task {
                try? await fetchData(fromStart: true)
            }
        }
    }

    @Published var state: State = .empty

    private let service: ApiService
    private var isEndOFData = false

    init(service: ApiService = .init()) {
        self.service = service
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
                state = .loading(currentAnimeModels, nextPage)
                let captureState = state

                do {
                    let animeModels = try await service.fetchTopAnime(type: type, subType: subType, page: nextPage)
                    guard captureState == state else { return }
                    state = .normal(currentAnimeModels + animeModels, nextPage)
                } catch {
                    // cannot load more anymore
                    guard captureState == state else { return }
                    state = .normal(currentAnimeModels, currentPage)
                    isEndOFData = true
                }
            }
        }
    }

    private func fetchDataFromStart() async {
        state = .loading([], Constant.PageStart)
        let captureState = state
        isEndOFData = false

        do {
            let animeModels = try await service.fetchTopAnime(type: type, subType: subType, page: Constant.PageStart)
            guard captureState == state else { return }
            state = .normal(animeModels, Constant.PageStart)
        } catch {
            guard captureState == state else { return }
            state = .error(error.localizedDescription)
        }
    }
}

// MARK: - Constants

extension AnimeViewModel {
    private enum Constant {
        static let PageStart = 1
    }
}
