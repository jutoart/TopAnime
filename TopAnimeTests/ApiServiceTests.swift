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
            for subType in AnimeType.anime.validSubTypes {
                let animeModels = try await sut.fetchTopAnime(type: .anime, subType: subType, page: 1)
                verifyAnimeModels(animeModels)
            }
            
            for subType in AnimeType.manga.validSubTypes {
                let animeModels = try await sut.fetchTopAnime(type: .manga, subType: subType, page: 1)
                verifyAnimeModels(animeModels)
            }
        } catch {
            XCTFail("Should be no error in response")
        }
    }
    
    func testFetchTopAnimeConfigurationError() async throws {
        urlSessionMock.response = .testRawModel
        
        for subType in AnimeType.anime.validSubTypes {
            guard !AnimeType.manga.validSubTypes.contains(subType) else { continue }
            
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
        
        for subType in AnimeType.manga.validSubTypes {
            guard !AnimeType.anime.validSubTypes.contains(subType) else { continue }
            
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
    
    private func verifyAnimeModels(_ animeModels: [AnimeModel]) {
        XCTAssertEqual(animeModels.count, 1) // only one test raw model
        XCTAssertEqual(animeModels.first?.rank, Constant.TestAnimeRawModel.top.first?.rank)
        XCTAssertEqual(animeModels.first?.title, Constant.TestAnimeRawModel.top.first?.title)
        XCTAssertEqual(animeModels.first?.type, Constant.TestAnimeRawModel.top.first?.type)
        XCTAssertEqual(animeModels.first?.startDate, Constant.TestAnimeRawModel.top.first?.startDate)
        XCTAssertEqual(animeModels.first?.endDate, Constant.TestAnimeRawModel.top.first?.endDate)
        
        if let testUrl = Constant.TestAnimeRawModel.top.first?.url {
            XCTAssertEqual(animeModels.first?.url, URL(string: testUrl))
        } else {
            XCTAssertNil(animeModels.first?.url)
        }
        
        if let testImageUrl = Constant.TestAnimeRawModel.top.first?.imageUrl {
            XCTAssertEqual(animeModels.first?.imageUrl, URL(string: testImageUrl))
        } else {
            XCTAssertNil(animeModels.first?.imageUrl)
        }
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
            XCTAssertEqual(url.pathComponents.count, 6, "There should be 6 components in path")
            XCTAssertEqual(url.pathComponents[1], "v3")
            XCTAssertEqual(url.pathComponents[2], "top")
            XCTAssertNotNil(AnimeType(rawValue: url.pathComponents[3]))
            XCTAssertNotNil(Int(url.pathComponents[4]))
            XCTAssertNotNil(AnimeSubType(rawValue: url.pathComponents[5]))
            
            let urlResponse = URLResponse(url: url, mimeType: "", expectedContentLength: .zero, textEncodingName: nil)
            
            switch response {
            case .apiError:
                throw ResponseError.apiError
            case .testRawModel:
                do {
                    let data = try Constant.JsonEncoder.encode(Constant.TestAnimeRawModel)
                    return (data, urlResponse)
                } catch {
                    throw ResponseError.testFailure
                }
            case .invalidRawModel:
                do {
                    let data = try Constant.JsonEncoder.encode(Constant.InvalidAnimeRawModel)
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
                        url: "https://myanimelist.net/anime/48583/Shingeki_no_Kyojin__The_Final_Season_Part_2",
                        imageUrl: "https://cdn.myanimelist.net/images/anime/1988/119437.jpg?s=aad31fb4d3d6d893c32a52ae666698ac",
                        type: "TV",
                        startDate: "Jan 2022",
                        endDate: nil)]
        )
        static let InvalidAnimeRawModel = "Invalid anime raw model"
        static let JsonEncoder: JSONEncoder = {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return encoder
        }()
    }
}
