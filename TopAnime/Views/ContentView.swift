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
    @State private var isFavoriteListViewPresented = false
    @StateObject private var viewModel = AnimeViewModel()
    @StateObject private var persistenceViewModel = PersistenceViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            AnimeListView(state: viewModel.state, favorites: persistenceViewModel.favorites) {
                Task(priority: .userInitiated) {
                    try? await viewModel.fetchData()
                }
            } favoriteAction: { (animeModel, isFavorite) in
                persistenceViewModel.setAnimeModel(animeModel, isFavorite: isFavorite)
            }
            VStack(spacing: 0) {
                VStack {
                    HStack {
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
                        Button {
                            isFavoriteListViewPresented.toggle()
                        } label: {
                            Image(systemName: "list.star")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 48)
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
                    .frame(height: 48)
                    Spacer()
                        .frame(height: 16)
                }
                .background(.regularMaterial)
                Spacer()
            }
        }
        .task {
            try? await viewModel.fetchData()
        }
        .sheet(isPresented: $isFavoriteListViewPresented) {
            FavoriteListView(persistenceViewModel: persistenceViewModel)
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
