//
//  JournalView.swift
//  Keepsake
//
//  Created by Chaerin Lee on 2/5/25.
//
import SwiftUI

struct HomepageView: View {
    var shelf: Shelf
    var journals: [Journal] = [
        Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(coverColor: .red, pageColor: .white, titleColor: .black)),
        Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(coverColor: .green, pageColor: .white, titleColor: .black)),
        Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(coverColor: .blue, pageColor: .black, titleColor: .white)),
        Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(coverColor: .brown, pageColor: .white, titleColor: .black))
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Welcome back, Name")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .bold()
                
                Text("What is on your mind today?")
                    .font(.largeTitle)
                    .bold()
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            .padding(.bottom, 20)
            
            //Journals
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 45) {
                    ForEach(shelf.books.indices, id: \.self) { index in
                        GeometryReader { geometry in
                            let verticalOffset = calculateVerticalOffset(proxy: geometry)
                            
                            VStack(spacing: 35) {
                                JournalCover(book: shelf.books[index])
                                VStack(spacing: 10) {
                                    //Journal name, date, created by you
                                    Text(journals[index].name)
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                    
                                    Text(journals[index].createdDate)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    HStack(spacing: 5) {
                                        Circle()
                                            .fill(Color.gray.opacity(0.5))
                                            .frame(width: 15, height: 15)
                                        
                                        Text("created by You")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .frame(width: 200)
                            }
                            .frame(width: 240, height: 700)
                            .offset(y: verticalOffset)
                        }
                        .frame(width: 240, height: 600)
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 500)
        }
        .frame(maxHeight: .infinity, alignment: .top)

    }
    
    private func calculateVerticalOffset(proxy: GeometryProxy) -> CGFloat {
        let midX = proxy.frame(in: .global).midX
        let screenMidX = UIScreen.main.bounds.midX
        let distance = abs(midX - screenMidX)
        let maxDistance: CGFloat = 200
        let centeredness = 1 - (distance / maxDistance)
        return -50 * centeredness
    }
}

#Preview {
    HomepageView(shelf: Shelf(name: "Bookshelf", books: [
        Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template(coverColor: .red, pageColor: .white, titleColor: .black)),
        Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(coverColor: .green, pageColor: .white, titleColor: .black)),
        Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template(coverColor: .blue, pageColor: .black, titleColor: .white)),
        Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template(coverColor: .brown, pageColor: .white, titleColor: .black))
    ]))
}
