//
//  AnimeTypeButton.swift
//  TopAnime
//
//  Created by Art Huang on 2021/12/15.
//  Copyright © 2021 Art Huang. All rights reserved.
//

import SwiftUI

struct AnimeTypeButton: View {
    var isSelected: Bool
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(title) {
            guard !isSelected else { return }
            action()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .font(.headline)
        .background(isSelected ? color : .clear)
        .foregroundColor(isSelected ? .white : color)
        .clipShape(Capsule())
        .overlay {
            Capsule().stroke(color, lineWidth: isSelected ? 0 : 2)
        }
        .padding(2)
    }
}

struct AnimeTypeButton_Previews: PreviewProvider {
    static var previews: some View {
        AnimeTypeButton(isSelected: false,
                        title: "Button",
                        color: .blue,
                        action: { })
    }
}
