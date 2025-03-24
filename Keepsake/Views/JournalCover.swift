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
    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 15) {
                VStack(alignment: .leading) {
                    Text("journal.name").font(.system(size: 40))
                    Text("journal.createdDate").font(.system(size: 20))
                    Text("created by...").font(.system(size: 15))
                }
                Spacer()
                Button(action: {
                }) {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding(.top, 8)
                        .foregroundColor(.black)
                }
            }.padding(.horizontal, 30)
                .opacity(0)
            ZStack {
                // Spine Effect
                Rectangle()
                    .fill(template.coverColor) // Darker than cover color
                    .brightness(-0.2)
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
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
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
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 5, y: 5) // Gives depth
                    
                    // Title
                    Text(title)
                        .font(.title)
                        .foregroundStyle(template.titleColor)
                }
                .rotation3DEffect(.degrees(0), axis: (x: 0.0, y: 1, z: 0.0), anchor: UnitPoint.leading, anchorZ: 0, perspective: 0.2)
            }
            HStack {
                Button(action: {
                }, label: {
                    Image(systemName: "return")
                        .resizable()
                        .foregroundStyle(.black)
                        .frame(width: UIScreen.main.bounds.width * 0.07, height: UIScreen.main.bounds.width * 0.07)
                }).frame(width: UIScreen.main.bounds.width * 0.1)
                Spacer()
                Button(action: {
                }, label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 45, height: 45)
                        .foregroundColor(.black)
                }).frame(width: UIScreen.main.bounds.width * 0.1)
            }.padding(.horizontal, 30)
                .opacity(0)
        }
    }
}
#Preview {
    JournalCover(template: Template(coverColor: .red, pageColor: .white, titleColor: .black), degrees: 0, title: "Journal Title")
}

//Color(red: 0.96, green: 0.5, blue: 0.5)
//Color(red: 0.96, green: 0.95, blue: 0.78)

