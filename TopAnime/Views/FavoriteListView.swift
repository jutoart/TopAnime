//
//  FavoriteListView.swift
//  TopAnime
//
//  Created by Curea Liu on 2021/12/16.
//  Copyright © 2021 Art Huang. All rights reserved.
//

import SwiftUI

struct FavoriteListView: View {
    let persistenceViewModel: PersistenceViewModel
    @Environment(\.dismiss) var dismiss

    private var animeModels: [AnimeModel] {
        Array(persistenceViewModel.favorites.values)
    }

    var body: some View {
        ZStack(alignment: .top) {
            if animeModels.isEmpty {
                InfoView(image: Constant.EmptyImage, message: Constant.EmptyMessage)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(animeModels) { animeModel in
                            AnimeView(animeModel: animeModel,
                                      isRankHidden: true,
                                      isFavorite: persistenceViewModel.favorites[animeModel.id] != nil) { (animeModel, isFavorite) in
                                persistenceViewModel.setAnimeModel(animeModel, isFavorite: isFavorite)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 72)
                }
            }
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                Spacer()
            }
            .padding()
            .background(.regularMaterial)
        }
    }
}

struct FavoriteListView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteListView(persistenceViewModel: .init())
    }
}

// MARK: - Constants

extension FavoriteListView {
    private enum Constant {
        static let EmptyImage = SwiftUI.Image(systemName: "magnifyingglass")
        static let EmptyMessage = "No Data"
    }
}
