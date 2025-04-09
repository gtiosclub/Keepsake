//
//  StickerView.swift
//  Keepsake
//
//  Created by Rik Roy on 4/9/25.
//

import SwiftUI

struct StickerView: View {
    @ObservedObject var sticker: Sticker
    @GestureState private var dragOffset = CGSize.zero
    
    var body: some View {
        if let url = URL(string: sticker.url) {
            AsyncImage(url: url) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .position(sticker.position)
                    .offset(dragOffset)
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation
                            }
                            .onEnded { value in
                                sticker.position.x += value.translation.width
                                sticker.position.y += value.translation.height
                            }
                    )
            } placeholder: {
                ProgressView()
            }
        }
    }
}


#Preview {
    StickerView(sticker: Sticker(url: ""))
}
