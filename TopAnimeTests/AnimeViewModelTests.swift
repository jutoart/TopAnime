//
//  AnimeViewModelTests.swift
//  TopAnimeTests
//
//  Created by Art Huang on 2021/12/15.
//  Copyright © 2021 Art Huang. All rights reserved.
//

import XCTest
import Combine
@testable import TopAnime

class AnimeViewModelTests: XCTestCase {
    private let apiServiceMock = ApiServiceMock()
    private lazy var sut = AnimeViewModel(service: apiServiceMock)

    override func setUpWithError() throws {
        apiServiceMock.result = nil
    }

    func testFetchDataStateEmpty() async {
        apiServiceMock.result = .success(Constant.TestAnimeModels)
        await sut.updateState(.empty)

        let expectation = expectation(description: "testFetchDataStateEmpty")
        let cancellabe = sut.$state.dropFirst().sink { [unowned self] (state) in
            switch state {
            case let .normal(animeModels, page):
                XCTAssertEqual(animeModels.count, Constant.TestAnimeModels.count)
                self.verifyAnimeModels(animeModels)
                XCTAssertEqual(page, 1)
                expectation.fulfill()
            case .empty, .loading, .error:
                break // no-op
            }
        }

        do {
            try await sut.fetchData()
        } catch {
            XCTFail("Should be no error for the request")
        }

        await waitForExpectations(timeout: Constant.ExpectionTimeout) { _ in
            cancellabe.cancel()
        }
    }

    func testFetchDataStateLoading() async {
        apiServiceMock.result = .success(Constant.TestAnimeModels)
        await sut.updateState(.loading([], 1))

        do {
            try await sut.fetchData()
            XCTFail("Should catch request error in this test")
        } catch {
            guard let requestError = error as? AnimeViewModel.RequestError else {
                XCTFail("Invalid error type")
                return
            }

            XCTAssertEqual(requestError, .isFetchingData)
        }

        switch sut.state {
        case let .loading(animeModels, page):
            XCTAssertEqual(animeModels.count, .zero)
            XCTAssertEqual(page, 1)
        case .empty, .normal, .error:
            break // no-op
        }
    }

    func testFetchDataStateNormal() async {
        // load more case
        apiServiceMock.result = .success(Constant.TestAnimeModels)
        await sut.updateState(.normal(Constant.TestAnimeModels, 1))

        let expectation = expectation(description: "testFetchDataStateEmpty")
        let cancellabe = sut.$state.dropFirst().sink { [unowned self] (state) in
            switch state {
            case let .normal(animeModels, page):
                XCTAssertEqual(animeModels.count, Constant.TestAnimeModels.count * 2)
                XCTAssertEqual(page, 2)

                if animeModels.count == Constant.TestAnimeModels.count * 2 {
                    self.verifyAnimeModels(Array(animeModels[0..<Constant.TestAnimeModels.count]))
                    self.verifyAnimeModels(Array(animeModels[Constant.TestAnimeModels.count..<Constant.TestAnimeModels.count * 2]))

                }

                expectation.fulfill()
            case .empty, .loading, .error:
                break // no-op
            }
        }

        do {
            try await sut.fetchData()
        } catch {
            XCTFail("Should be no error for the request")
        }

        await waitForExpectations(timeout: Constant.ExpectionTimeout) { _ in
            cancellabe.cancel()
        }
    }

    func testFetchDataStateError() async {
        // result should be the same with the empty case
        apiServiceMock.result = .success(Constant.TestAnimeModels)
        await sut.updateState(.error(Constant.TestErrorDescription))

        let expectation = expectation(description: "testFetchDataStateEmpty")
        let cancellabe = sut.$state.dropFirst().sink { [unowned self] (state) in
            switch state {
            case let .normal(animeModels, page):
                XCTAssertEqual(animeModels.count, Constant.TestAnimeModels.count)
                self.verifyAnimeModels(animeModels)
                XCTAssertEqual(page, 1)
                expectation.fulfill()
            case .empty, .loading, .error:
                break // no-op
            }
        }

        do {
            try await sut.fetchData()
        } catch {
            XCTFail("Should be no error for the request")
        }

        await waitForExpectations(timeout: Constant.ExpectionTimeout) { _ in
            cancellabe.cancel()
        }
    }

    func testFetchDataFromStart() async {
        apiServiceMock.result = .success(Constant.TestAnimeModels)

        // no matter what current state is, fetch data from start will have the same next state if fetch successfully
        for state in [AnimeViewModel.State.empty, .loading([], 1), .normal(Constant.TestAnimeModels, 1), .error(Constant.TestErrorDescription)] {
            await sut.updateState(state)

            let expectation = expectation(description: "testFetchDataStateEmpty")
            let cancellabe = sut.$state.dropFirst().sink { [unowned self] (state) in
                switch state {
                case let .normal(animeModels, page):
                    XCTAssertEqual(animeModels.count, Constant.TestAnimeModels.count)
                    self.verifyAnimeModels(animeModels)
                    XCTAssertEqual(page, 1)
                    expectation.fulfill()
                case .empty, .loading, .error:
                    break // no-op
                }
            }

            do {
                try await sut.fetchData(fromStart: true)
            } catch {
                XCTFail("Should be no error for the request")
            }

            await waitForExpectations(timeout: Constant.ExpectionTimeout) { _ in
                cancellabe.cancel()
            }
        }
    }

    func testFetchDataErrorStateEmpty() async {
        apiServiceMock.result = .failure(.apiError)
        await sut.updateState(.empty)

        let expectation = expectation(description: "testFetchDataStateEmpty")
        let cancellabe = sut.$state.dropFirst().sink { state in
            switch state {
            case let .error(errorDescription):
                XCTAssertEqual(errorDescription, ApiServiceError.apiError.localizedDescription)
                expectation.fulfill()
            case .empty, .loading, .normal:
                break // no-op
            }
        }

        do {
            try await sut.fetchData()
        } catch {
            XCTFail("Should be no error for the request")
        }

        await waitForExpectations(timeout: Constant.ExpectionTimeout) { _ in
            cancellabe.cancel()
        }
    }

    func testFetchDataErrorStateNormal() async {
        // load more case
        apiServiceMock.result = .failure(.apiError)
        await sut.updateState(.normal(Constant.TestAnimeModels, 1))

        let expectation = expectation(description: "testFetchDataStateEmpty")
        let cancellabe = sut.$state.dropFirst().sink { [unowned self] (state) in
            switch state {
            case let .normal(animeModels, page):
                XCTAssertEqual(animeModels.count, Constant.TestAnimeModels.count)
                self.verifyAnimeModels(animeModels)
                XCTAssertEqual(page, 1)
                expectation.fulfill()
            case .empty, .loading, .error:
                break // no-op
            }
        }

        do {
            try await sut.fetchData()
        } catch {
            XCTFail("Should be no error for the request")
        }

        await waitForExpectations(timeout: Constant.ExpectionTimeout) { _ in
            cancellabe.cancel()
        }
    }

    func testFetchDataFromStartErrorStateNormal() async {
        // not load more case
        apiServiceMock.result = .failure(.apiError)
        await sut.updateState(.normal(Constant.TestAnimeModels, 1))

        let expectation = expectation(description: "testFetchDataStateEmpty")
        let cancellabe = sut.$state.dropFirst().sink { state in
            switch state {
            case let .error(errorDescription):
                XCTAssertEqual(errorDescription, ApiServiceError.apiError.localizedDescription)
                expectation.fulfill()
            case .empty, .loading, .normal:
                break // no-op
            }
        }

        do {
            try await sut.fetchData(fromStart: true)
        } catch {
            XCTFail("Should be no error for the request")
        }

        await waitForExpectations(timeout: Constant.ExpectionTimeout) { _ in
            cancellabe.cancel()
        }
    }

    func testFetchDataErrorStateError() async {
        apiServiceMock.result = .failure(.apiError)
        await sut.updateState(.error(Constant.TestErrorDescription))

        let expectation = expectation(description: "testFetchDataStateEmpty")
        let cancellabe = sut.$state.dropFirst().sink { state in
            switch state {
            case let .error(errorDescription):
                XCTAssertEqual(errorDescription, ApiServiceError.apiError.localizedDescription)
                expectation.fulfill()
            case .empty, .loading, .normal:
                break // no-op
            }
        }

        do {
            try await sut.fetchData()
        } catch {
            XCTFail("Should be no error for the request")
        }

        await waitForExpectations(timeout: Constant.ExpectionTimeout) { _ in
            cancellabe.cancel()
        }
    }

    private func verifyAnimeModels(_ animeModels: [AnimeModel]) {
        zip(animeModels, Constant.TestAnimeModels).forEach { (animeModel, testAnimeModel) in
            XCTAssertEqual(animeModel.rank, testAnimeModel.rank)
            XCTAssertEqual(animeModel.title, testAnimeModel.title)
            XCTAssertEqual(animeModel.url, testAnimeModel.url)
            XCTAssertEqual(animeModel.imageUrl, testAnimeModel.imageUrl)
            XCTAssertEqual(animeModel.type, testAnimeModel.type)
            XCTAssertEqual(animeModel.startDate, testAnimeModel.startDate)
            XCTAssertEqual(animeModel.endDate, testAnimeModel.endDate)
        }
    }
}

// MARK: - Mocks

extension AnimeViewModelTests {
    private class ApiServiceMock: ApiService {
        var result: Result<[AnimeModel], ApiServiceError>?
        var expectedPage: Int?

        override func fetchTopAnime(type: AnimeType, subType: AnimeSubType, page: Int) async throws -> [AnimeModel] {
            if let expectedPage = expectedPage {
                XCTAssertEqual(page, expectedPage)
            }

            switch result {
            case let .success(animeModels):
                return animeModels
            case let .failure(error):
                throw error
            case .none:
                XCTFail("Should set expected result in test case")
                return []
            }
        }
    }
}

// MARK: - Constants

extension AnimeViewModelTests {
    private enum Constant {
        static let ExpectionTimeout: TimeInterval = 3
        static let TestErrorDescription = UUID().uuidString
        static let TestAnimeModels = [AnimeModel(
            id: "48583",
            rank: 1,
            title: "Shingeki no Kyojin: The Final Season Part 2",
            url: URL(string: "https://myanimelist.net/anime/48583/Shingeki_no_Kyojin__The_Final_Season_Part_2"),
            imageUrl: URL(string: "https://cdn.myanimelist.net/images/anime/1988/119437.jpg?s=aad31fb4d3d6d893c32a52ae666698ac"),
            type: "TV",
            startDate: "Jan 2022",
            endDate: nil
        )]
    }
}
