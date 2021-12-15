//
//  ContentView.swift
//  TopAnime
//
//  Created by Art Huang on 2021/12/14.
//  Copyright © 2021 Art Huang. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    private let animeTypes = AnimeType.allCases
    private var animeSubTypes: [AnimeSubType] { selectedAnimeType.validSubTypes }

    @State private var selectedAnimeType: AnimeType = .anime
    @State private var selectedAnimeSubType: AnimeSubType = .airing
    @StateObject private var viewModel = AnimeViewModel()

    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 4) {
                    ForEach(animeTypes, id: \.self) { animeType in
                        AnimeTypeButton(isSelected: selectedAnimeType == animeType,
                                        title: animeType.description,
                                        color: Constant.Color.AnimeType) {
                            selectedAnimeType = animeType
                            selectedAnimeSubType = animeSubTypes.first!
                            viewModel.type = selectedAnimeType
                            viewModel.subType = selectedAnimeSubType
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 44)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 4) {
                    ForEach(animeSubTypes, id: \.self) { animeSubType in
                        AnimeTypeButton(isSelected: selectedAnimeSubType == animeSubType,
                                        title: animeSubType.description,
                                        color: Constant.Color.AnimeSubType) {
                            selectedAnimeSubType = animeSubType
                            viewModel.subType = selectedAnimeSubType
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 44)
            AnimeListView(state: $viewModel.state)
        }
        .task {
            try? await viewModel.fetchData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - Constants

extension ContentView {
    private enum Constant {
        enum Color {
            static let AnimeType: SwiftUI.Color = .blue
            static let AnimeSubType: SwiftUI.Color = .green
        }
    }
}
