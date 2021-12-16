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
                let captureState: State = .loading(currentAnimeModels, nextPage)
                updateState(captureState)

                do {
                    let animeModels = try await service.fetchTopAnime(type: type, subType: subType, page: nextPage)
                    guard captureState == state else { return }
                    updateState(.normal(currentAnimeModels + animeModels, nextPage))
                } catch {
                    // cannot load more anymore
                    guard captureState == state else { return }
                    updateState(.normal(currentAnimeModels, currentPage))
                    isEndOFData = true
                }
            }
        }
    }

    private func fetchDataFromStart() async {
        let captureState: State = .loading([], Constant.PageStart)
        updateState(captureState)
        isEndOFData = false

        do {
            let animeModels = try await service.fetchTopAnime(type: type, subType: subType, page: Constant.PageStart)
            guard captureState == state else { return }
            updateState(.normal(animeModels, Constant.PageStart))
        } catch {
            guard captureState == state else { return }
            updateState(.error(error.localizedDescription))
        }
    }

    private func updateState(_ state: State) {
        Task { @MainActor in
            self.state = state
        }
    }
}

// MARK: - Constants

extension AnimeViewModel {
    private enum Constant {
        static let PageStart = 1
    }
}
