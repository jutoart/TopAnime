//
//  InfoView.swift
//  TopAnime
//
//  Created by Art Huang on 2021/12/16.
//  Copyright © 2021 Art Huang. All rights reserved.
//

import SwiftUI

struct InfoView: View {
    let image: Image?
    let message: String

    var body: some View {
        VStack {
            if let image = image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
            }
            Text(message)
                .font(.title2)
                .padding()
        }
        .frame(maxHeight: .infinity)
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(image: Image(systemName: "exclamationmark.bubble"), message: "Error")
    }
}
