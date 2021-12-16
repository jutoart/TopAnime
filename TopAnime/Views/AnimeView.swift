//
//  AnimeView.swift
//  TopAnime
//
//  Created by Art Huang on 2021/12/16.
//  Copyright © 2021 Art Huang. All rights reserved.
//

import SwiftUI

struct AnimeView: View {
    let animeModel: AnimeModel
    @State var isFavorite: Bool
    @State private var isSafariViewPresented = false
    let favoriteAction: (AnimeModel, Bool) -> Void

    var period: String {
        switch (animeModel.startDate, animeModel.endDate) {
        case (.none, _): return ""
        case let (.some(start), .none): return "\(start) – present"
        case let (.some(start), .some(end)): return "\(start) – \(end)"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(animeModel.rank)")
                .font(.title)
                .lineLimit(1)
                .minimumScaleFactor(0.33)
                .padding(.vertical, 8)
                .frame(width: 20)
            AsyncImage(url: animeModel.imageUrl) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray
            }
            .frame(width: 80, height: 128)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            VStack(alignment: .leading, spacing: 8) {
                Text(animeModel.title)
                    .font(.headline)
                Text(animeModel.type)
                Text(period)
                    .font(.footnote)
            }
            .padding(.vertical, 8)
            Spacer()
            Button {
                isFavorite.toggle()
                favoriteAction(animeModel, isFavorite)
            } label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .resizable()
                    .scaledToFit()
            }
            .accentColor(.red)
            .frame(width: 24, height: 24)
            .padding(.vertical, 8)
        }
        .onTapGesture {
            guard animeModel.url != nil else { return }
            isSafariViewPresented.toggle()
        }
        .sheet(isPresented: $isSafariViewPresented) {
            SafariView(url: animeModel.url!)
        }
    }
}

struct AnimeView_Previews: PreviewProvider {
    static var previews: some View {
        AnimeView(animeModel: .init(id: "48583",
                                    rank: 1,
                                    title: "Shingeki no Kyojin: The Final Season Part 2",
                                    url: URL(string: "https://myanimelist.net/anime/48583/Shingeki_no_Kyojin__The_Final_Season_Part_2"),
                                    imageUrl: URL(string: "https://cdn.myanimelist.net/images/anime/1988/119437.jpg?s=aad31fb4d3d6d893c32a52ae666698ac"),
                                    type: "TV",
                                    startDate: "Jan 2022",
                                    endDate: nil),
                  isFavorite: false,
                  favoriteAction: { (_, _) in })
    }
}
