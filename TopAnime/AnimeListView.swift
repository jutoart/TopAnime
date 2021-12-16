//
//  AnimeListView.swift
//  TopAnime
//
//  Created by Art Huang on 2021/12/16.
//  Copyright © 2021 Art Huang. All rights reserved.
//

import SwiftUI

struct AnimeListView: View {
    @Binding var state: AnimeViewModel.State

    var body: some View {
        switch state {
        case .empty:
            InfoView(image: Constant.Image.Empty, message: Constant.Message.Empty)
        case let .loading(animeModels, _):
            if animeModels.isEmpty {
                InfoView(image: nil, message: Constant.Message.Loading)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(animeModels) { animeModel in
                            AnimeView(animeModel: animeModel)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 136)
                }
            }
        case let .normal(animeModels, _):
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(animeModels) { animeModel in
                        AnimeView(animeModel: animeModel)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 136)
            }
        case let .error(description):
            InfoView(image: Constant.Image.Error, message: description)
        }
    }
}

struct AnimeListView_Previews: PreviewProvider {
    static var previews: some View {
        AnimeListView(state: .constant(.empty))
    }
}

// MARK: - Constants

extension AnimeListView {
    private enum Constant {
        enum Image {
            static let Empty = SwiftUI.Image(systemName: "magnifyingglass")
            static let Error = SwiftUI.Image(systemName: "exclamationmark.bubble")
        }

        enum Message {
            static let Empty = "No Data"
            static let Loading = "Loading..."
        }
    }
}
