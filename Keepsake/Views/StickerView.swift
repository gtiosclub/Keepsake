//
//  StickerView.swift
//  Keepsake
//
//  Created by Rik Roy on 4/9/25.
//

import SwiftUI

struct StickerView: View {
    let url: String
    
    var body: some View {
        if let url = URL(string: url) {
            AsyncImage(url: url) { image in
                image.resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
        }
    }
}


#Preview {
    StickerView(url: "")
}
