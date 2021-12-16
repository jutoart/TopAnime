//
//  ApiServiceProvider.swift
//  TopAnime
//
//  Created by Art Haung on 2021/12/15.
//  Copyright © 2021 Art Huang. All rights reserved.
//

import Foundation

protocol ApiServiceProvider {
    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

extension URLSession: ApiServiceProvider { }
