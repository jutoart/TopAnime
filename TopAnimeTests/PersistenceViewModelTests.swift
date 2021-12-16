//
//  PersistenceViewModelTests.swift
//  TopAnimeTests
//
//  Created by Curea Liu on 2021/12/16.
//  Copyright © 2021 Art Huang. All rights reserved.
//

import XCTest
@testable import TopAnime

class PersistenceViewModelTests: XCTestCase {
    private let persistenceServiceMock = PersistenceServiceMock()
    private var sut: PersistenceViewModel!

    func testInitialFavorites() {
        persistenceServiceMock.initialFavorites = nil
        sut = .init(persistenceService: persistenceServiceMock)
        XCTAssertTrue(sut.favorites.isEmpty)

        persistenceServiceMock.initialFavorites = Constant.TestFavorites
        sut = .init(persistenceService: persistenceServiceMock)
        XCTAssertFalse(sut.favorites.isEmpty)
        XCTAssertNotNil(sut.favorites[Constant.TestAnimeModel.id])
    }

    func testSetAnimeModelFavorite() {
        persistenceServiceMock.initialFavorites = nil
        persistenceServiceMock.isSetValueCalled = false
        sut = .init(persistenceService: persistenceServiceMock)
        sut.setAnimeModel(Constant.TestAnimeModel, isFavorite: true)
        XCTAssertTrue(persistenceServiceMock.isSetValueCalled)
        XCTAssertFalse(sut.favorites.isEmpty)
        XCTAssertNotNil(sut.favorites[Constant.TestAnimeModel.id])

        persistenceServiceMock.isSetValueCalled = false
        sut.setAnimeModel(Constant.TestAnimeModel, isFavorite: false)
        XCTAssertTrue(persistenceServiceMock.isSetValueCalled)
        XCTAssertTrue(sut.favorites.isEmpty)
    }
}

// MARK: - Mocks

extension PersistenceViewModelTests {
    private class PersistenceServiceMock: UserDefaults {
        var initialFavorites: [String: AnimeModel]?
        var isSetValueCalled = false

        override func object(forKey defaultName: String) -> Any? {
            guard let favorites = initialFavorites else { return nil }
            return try? JSONEncoder().encode(favorites)
        }

        override func set(_ value: Any?, forKey defaultName: String) {
            isSetValueCalled = true
        }
    }
}

// MARK - Constants

extension PersistenceViewModelTests {
    private enum Constant {
        static let TestAnimeModel = AnimeModel(
            rank: 1,
            title: "Shingeki no Kyojin: The Final Season Part 2",
            url: URL(string: "https://myanimelist.net/anime/48583/Shingeki_no_Kyojin__The_Final_Season_Part_2"),
            imageUrl: URL(string: "https://cdn.myanimelist.net/images/anime/1988/119437.jpg?s=aad31fb4d3d6d893c32a52ae666698ac"),
            type: "TV",
            startDate: "Jan 2022",
            endDate: nil
        )
        static let TestFavorites = [TestAnimeModel.id: TestAnimeModel]
    }
}
