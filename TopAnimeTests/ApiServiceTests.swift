//
//  ApiServiceTests.swift
//  TopAnimeTests
//
//  Created by Art Huang on 2021/12/15.
//  Copyright © 2021 Art Huang. All rights reserved.
//

import XCTest
@testable import TopAnime

class ApiServiceTests: XCTestCase {
    private let urlSessionMock = URLSessionMock()
    private lazy var sut = ApiService(serviceProvider: urlSessionMock)
    
    override func setUpWithError() throws {
        urlSessionMock.response = nil
    }
    
    func testFetchTopAnime() async {
        urlSessionMock.response = .testRawModel
        
        do {
            for subType in Constant.SubTypeMap.Anime {
                let animeRawModel = try await sut.fetchTopAnime(type: .anime, subType: subType, page: 1)
                verifyAnimeRawModel(animeRawModel)
            }
            
            for subType in Constant.SubTypeMap.Manga {
                let animeRawModel = try await sut.fetchTopAnime(type: .manga, subType: subType, page: 1)
                verifyAnimeRawModel(animeRawModel)
            }
            
            for subType in Constant.SubTypeMap.Both {
                let animeRawModel = try await sut.fetchTopAnime(type: .anime, subType: subType, page: 1)
                verifyAnimeRawModel(animeRawModel)
                let mangaRawModel = try await sut.fetchTopAnime(type: .manga, subType: subType, page: 1)
                verifyAnimeRawModel(mangaRawModel)
            }
        } catch {
            XCTFail("Should be no error in response")
        }
    }
    
    func testFetchTopAnimeConfigurationError() async throws {
        urlSessionMock.response = .testRawModel
        
        for subType in Constant.SubTypeMap.Anime {
            do {
                _ = try await sut.fetchTopAnime(type: .manga, subType: subType, page: 1)
                XCTFail("Should catch configuration error in this test")
            } catch {
                guard let responseError = error as? ApiServiceError else {
                    XCTFail("Invalid error type")
                    return
                }
                
                XCTAssertEqual(responseError, .configurationError)
            }
        }
        
        for subType in Constant.SubTypeMap.Manga {
            do {
                _ = try await sut.fetchTopAnime(type: .anime, subType: subType, page: 1)
                XCTFail("Should catch configuration error in this test")
            } catch {
                guard let responseError = error as? ApiServiceError else {
                    XCTFail("Invalid error type")
                    return
                }
                
                XCTAssertEqual(responseError, .configurationError)
            }
        }
    }
    
    func testFetchTopAnimeApiError() async {
        urlSessionMock.response = .apiError
        
        do {
            _ = try await sut.fetchTopAnime(type: .anime, subType: .airing, page: 1)
            XCTFail("Should catch API error in this test")
        } catch let error {
            guard let responseError = error as? ApiServiceError else {
                XCTFail("Invalid error type")
                return
            }
            
            XCTAssertEqual(responseError, .apiError)
        }
    }
    
    func testFetchTopAnimeInvalidData() async throws {
        urlSessionMock.response = .invalidRawModel
        
        do {
            _ = try await sut.fetchTopAnime(type: .anime, subType: .airing, page: 1)
            XCTFail("Should catch invalid data error in this test")
        } catch let error {
            guard let responseError = error as? ApiServiceError else {
                XCTFail("Invalid error type")
                return
            }
            
            XCTAssertEqual(responseError, .invalidData)
        }
    }
    
    private func verifyAnimeRawModel(_ animeRawModel: AnimeRawModel) {
        XCTAssertEqual(animeRawModel.requestHash, Constant.TestAnimeRawModel.requestHash)
        XCTAssertEqual(animeRawModel.top.first?.rank, Constant.TestAnimeRawModel.top.first?.rank)
        XCTAssertEqual(animeRawModel.top.first?.title, Constant.TestAnimeRawModel.top.first?.title)
        XCTAssertEqual(animeRawModel.top.first?.url, Constant.TestAnimeRawModel.top.first?.url)
        XCTAssertEqual(animeRawModel.top.first?.imageUrl, Constant.TestAnimeRawModel.top.first?.imageUrl)
        XCTAssertEqual(animeRawModel.top.first?.type, Constant.TestAnimeRawModel.top.first?.type)
        XCTAssertEqual(animeRawModel.top.first?.startDate, Constant.TestAnimeRawModel.top.first?.startDate)
        XCTAssertEqual(animeRawModel.top.first?.endDate, Constant.TestAnimeRawModel.top.first?.endDate)
    }
}

// MARK: - Mocks

extension ApiServiceTests {
    private class URLSessionMock: ApiServiceProvider {
        enum Response {
            case apiError
            case testRawModel
            case invalidRawModel
        }
        
        enum ResponseError: Error {
            case apiError
            case testFailure
        }
        
        var response: Response?
        
        func data(from url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
            XCTAssertNotNil(response, "Should set expected response in test case")
            
            // verify path components
            XCTAssertEqual(url.pathComponents.count, 5, "There should be 5 components in path")
            XCTAssertEqual(url.pathComponents[0], "v3")
            XCTAssertEqual(url.pathComponents[1], "top")
            XCTAssertNotNil(AnimeType(rawValue: url.pathComponents[2]))
            XCTAssertNotNil(Int(url.pathComponents[3]))
            XCTAssertNotNil(AnimeSubType(rawValue: url.pathComponents[4]))
            
            let urlResponse = URLResponse(url: url, mimeType: "", expectedContentLength: .zero, textEncodingName: nil)
            
            switch response {
            case .apiError:
                throw ResponseError.apiError
            case .testRawModel:
                do {
                    let data = try JSONSerialization.data(withJSONObject: Constant.TestAnimeRawModel, options: [])
                    return (data, urlResponse)
                } catch {
                    throw ResponseError.testFailure
                }
            case .invalidRawModel:
                do {
                    let data = try JSONSerialization.data(withJSONObject: Constant.InvalidAnimeRawModel, options: [])
                    return (data, urlResponse)
                } catch {
                    throw ResponseError.testFailure
                }
            case .none:
                throw ResponseError.testFailure
            }
        }
    }
}

// MARK: - Constants

extension ApiServiceTests {
    private enum Constant {
        static let TestAnimeRawModel = AnimeRawModel(
            requestHash: UUID().uuidString,
            top: [.init(rank: 1,
                        title: "Shingeki no Kyojin: The Final Season Part 2",
                        url: URL(string: "https://myanimelist.net/anime/48583/Shingeki_no_Kyojin__The_Final_Season_Part_2"),
                        imageUrl: URL(string: "https://cdn.myanimelist.net/images/anime/1988/119437.jpg?s=aad31fb4d3d6d893c32a52ae666698ac"),
                        type: "TV",
                        startDate: "Jan 2022",
                        endDate: nil)]
        )
        static let InvalidAnimeRawModel = "Invalid anime raw model"
        
        enum SubTypeMap {
            static let Anime: [AnimeSubType] = [.airing, .upcoming, .tv, .movie, .ova, .special]
            static let Manga: [AnimeSubType] = [.manga, .novels, .oneshots, .doujin, .manhwa, .manhua]
            static let Both: [AnimeSubType] = [.bypopularity, .favorite]
        }
    }
}
