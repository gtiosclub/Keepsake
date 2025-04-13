//
//  JournalCover.swift
//  Keepsake
//
//  Created by Alec Hance on 2/10/25.
//


import SwiftUI

struct JournalCover: View {
    @State var template: Template
//    @Binding var degrees: CGFloat
    @State var degrees: CGFloat
    @State var title: String
    @Binding var showOnlyCover: Bool
    var offset: Bool
    var body: some View {
        ZStack {
            // Spine Effect
            Rectangle()
                .fill(template.coverColor) // Darker than cover color
                .brightness(showOnlyCover ? 0 : -0.2)
                .frame(width: UIScreen.main.bounds.width * 0.1, height: UIScreen.main.bounds.height * 0.56)
                .offset(x: UIScreen.main.bounds.width * -0.42)
                .zIndex(-3)
                .overlay(
                    Image("\(template.texture)") // Load texture image from assets
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width * 0.1, height: UIScreen.main.bounds.height * 0.56)
                        .offset(x: UIScreen.main.bounds.width * -0.42)
                        .scaledToFill()
                        .opacity(0.4) // Adjust for realism
                )
            RoundedRectangle(cornerRadius: 10)
                .fill(template.coverColor)
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.56)
                .shadow(color: .black.opacity(0.3), radius: 5, x: 5, y: 5)
            ZStack {
                RoundedRectangle(cornerRadius : 10)
                    .fill(template.coverColor)
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.56)
                    .overlay(
                        Image("\(template.texture)") // Load texture image from assets
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.56)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .scaledToFill()
                            .opacity(0.4) // Adjust for realism
                    )
//                    .shadow(color: .black.opacity(0.3), radius: 5, x: 5, y: 5) // Gives depth
                
                // Title
                Text(title)
                    .font(.title)
                    .foregroundStyle(template.titleColor)
            }
            .rotation3DEffect(.degrees(0), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint.leading, anchorZ: 0, perspective: 0.2)
        }.offset(y: offset ? UIScreen.main.bounds.height * 0.05 : 0)
        
    }
}
#Preview {
    struct Preview: View {
        @State var showOnlyCover: Bool = false
        var body: some View {
            JournalCover(template: Template(coverColor: .red, pageColor: .white, titleColor: .black), degrees: 0, title: "TITLE", showOnlyCover: $showOnlyCover, offset: false)        }
    }

    return Preview()
}

//Color(red: 0.96, green: 0.5, blue: 0.5)
//Color(red: 0.96, green: 0.95, blue: 0.78)

