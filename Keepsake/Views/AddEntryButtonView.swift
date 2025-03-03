//
//  AddEntryButtonView.swift
//  Keepsake
//
//  Created by Alec Hance on 2/26/25.
//

import SwiftUI

struct AddEntryButtonView: View {
    @State var isExpanded: Bool = false
    var body: some View {
        HStack {
            if !isExpanded {
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 45, height: 45)
                        .foregroundColor(.red)

                }
            }
            if isExpanded {
                HStack {
                    Button(action: {
                        
                        
                    }) { Image(systemName: "t.square.fill")
                            .resizable()
                            .frame(width: 45, height: 45)
                        .foregroundColor(.black)}
                    Button(action: {}) {Image(systemName: "photo.fill")
                            .resizable()
                            .frame(width: 45, height: 45)
                        .foregroundColor(.blue)}
                    Button(action:{}) {Image(systemName: "face.smiling.inverse")
                            .resizable()
                            .frame(width: 45, height: 45)
                        .foregroundColor(.yellow)}
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                                        isExpanded.toggle()
                                    }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 45, height: 45)
                        .foregroundColor(.red)}
                }.transition(.move(edge: .trailing).combined(with: .opacity))
                .padding(.trailing, 10)
            }
        }
    }
}

#Preview {
    AddEntryButtonView()
}
