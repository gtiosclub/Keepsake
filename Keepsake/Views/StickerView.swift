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
    
    @Binding var isWiggling: Bool
    @Binding var showDeleteButton: UUID?  // Keep as UUID?
    var deleteAction: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                if let url = URL(string: sticker.url) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    } placeholder: {
                        ProgressView()
                    }
                    .onTapGesture {
                        if showDeleteButton == sticker.id {
                            showDeleteButton = nil
                            isWiggling = false
                        }
                    }
                    .onLongPressGesture {
                        if isWiggling == true {
                            isWiggling = false
                            showDeleteButton = nil
                        } else {
                            withAnimation {
                                showDeleteButton = sticker.id
                                isWiggling = true
                            }
                        }
                    }
                }

                // Always keep the button in the view, but control visibility with opacity
                Button {
                    deleteAction()
                    withAnimation {
                        showDeleteButton = nil
                        isWiggling = false
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 25, height: 25)
                        Image(systemName: "minus")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .opacity(showDeleteButton != nil && showDeleteButton == sticker.id ? 1 : 0) // Instead of removing the button, fade it in/out
                .animation(.easeInOut(duration: 0.2), value: showDeleteButton) // Smooth fade effect

            }
            .rotationEffect(.degrees(isWiggling && showDeleteButton == sticker.id ? 2 : 0)) // Wiggle effect
            .animation(isWiggling && showDeleteButton == sticker.id ?
                       Animation.easeInOut(duration: 0.1).repeatForever(autoreverses: true)
                       : .default, value: isWiggling)
            .frame(width: sticker.size, height: sticker.size)
            .position(sticker.position)
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        let newX = sticker.position.x + value.translation.width
                        let newY = sticker.position.y + value.translation.height
                        
                        // Constrain horizontal movement (keep full sticker visible)
                        let minX = sticker.size/2
                        let maxX = geometry.size.width - sticker.size/2
                        
                        // Allow more vertical movement (let parts go off-screen)
                        let verticalBuffer = sticker.size * 0.05 // 50% of sticker can go off-screen
                        let minY = -verticalBuffer
                        let maxY = geometry.size.height + verticalBuffer
                        
                        sticker.position.x = min(max(newX, minX), maxX)
                        sticker.position.y = min(max(newY, minY), maxY)
                    }
            )
        }
    }
}

#Preview {
    StickerView(sticker: Sticker(url: ""), isWiggling: .constant(false), showDeleteButton: .constant(UUID()), deleteAction: {})
}

//
//  StickerView.swift
//  Keepsake
//
//  Created by Rik Roy on 4/9/25.
//

//import SwiftUI
//
//struct StickerView: View {
//    @ObservedObject var sticker: Sticker
//    @GestureState private var dragOffset = CGSize.zero
//    
//    var body: some View {
//        if let url = URL(string: sticker.url) {
//            AsyncImage(url: url) { image in
//                image.resizable()
//                    .scaledToFit()
//                    .frame(width: 100, height: 100)
//                    .position(sticker.position)
//                    .offset(dragOffset)
//                    .gesture(
//                        DragGesture()
//                            .updating($dragOffset) { value, state, _ in
//                                state = value.translation
//                            }
//                            .onEnded { value in
//                                sticker.position.x += value.translation.width
//                                sticker.position.y += value.translation.height
//                            }
//                    )
//            } placeholder: {
//                ProgressView()
//            }
//        }
//    }
//}
//
//
//#Preview {
//    StickerView(sticker: Sticker(url: ""))
//}
