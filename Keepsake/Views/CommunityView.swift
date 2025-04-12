//
//  CommunityView.swift
//  Keepsake
//
//  Created by Connor on 2/5/25.
//
import SwiftUI

var journals: [any Book] = [
    Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(coverColor: .red, pageColor: .white, titleColor: .black), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 2),
//    Scrapbook(name: "Scrapbook 1", createdDate: "5/7/25", entries: [], category: "category", isSaved: true, isShared: true, template: Template(coverColor: .cyan, pageColor: .white, titleColor: .black)),
    Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(coverColor: .blue, pageColor: .yellow, titleColor: .black), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
//    Scrapbook(name: "Scarpbook 2", createdDate: "5/4/25", entries: [], category: "category", isSaved: true, isShared: true, template: Template(coverColor: .orange, pageColor: .white, titleColor: .black)),
    Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(coverColor: .gray, pageColor: .brown, titleColor: .yellow), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
    Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template(coverColor: .green, pageColor: .white, titleColor: .black), pages: [JournalPage(number: 1), JournalPage(number: 2), JournalPage(number: 3), JournalPage(number: 4), JournalPage(number: 5)], currentPage: 0),
//    Scrapbook(name: "Scarpbook 3", createdDate: "5/9/25", entries: [], category: "category", isSaved: true, isShared: true, template: Template(coverColor: .black, pageColor: .white, titleColor: .white))
]

var sortOptions: [String] = ["↑↓", "Your Friends", "Travel", "Near You"]

struct CommunityView: View {
    @State var scaleEffect = 0.4
    @State private var searchText = ""
    @StateObject private var viewModel = UserLookupViewModel()
    @State var dummy: Bool = false
    var body: some View {
        NavigationStack {
            ScrollView (.vertical, showsIndicators: false) {
                VStack (alignment: .leading) {
                    HStack {
                        Text("Your Community")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                    }
                    NavigationLink(destination: UserSearchView()) {
                        HStack {
                            
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            

                            Text("Search for users...")
                                .foregroundColor(.gray)
                                
                            Spacer()
                            
                            
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(25)
                        .overlay( // Adding a black outline
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.black, lineWidth: 0.5)
                        )
                        .padding(.horizontal)
                    }
                    .padding(.bottom)

                    
                    
                    // Sorting buttons
                    HStack (spacing: 10){
                        ForEach(sortOptions, id:\.self) { option in
                            SortOptionButton(label: option) {print("option")}}
                    }
                    .padding(.horizontal)
                    
                    ForEach(0..<(journals.count / 2) + (journals.count % 2), id: \.self) { row in
                        // logic because Journals are not currently from db
                        HStack(spacing: 25) {
                            ForEach(0..<2, id: \.self) { column in
                                let index = row * 2 + column
                                if index < journals.count {
                                    VStack(alignment: .leading) {
                                        //                                    Rectangle()
                                        //                                        .fill(Color.gray.opacity(0.5))
                                        //                                        .frame(width: 150, height: 200)
                                        //                                        .cornerRadius(10)
                                        JournalCover(template: journals[index].template, degrees: 0, title: journals[index].name, showOnlyCover: $dummy, offset: false)
                                            .scaleEffect(scaleEffect)
                                            .frame(width: UIScreen.main.bounds.width * 0.92 * scaleEffect, height: UIScreen.main.bounds.height * 0.56 * scaleEffect)
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(journals[index].name)
                                                .font(.headline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                            HStack(spacing: 5) {
                                                Circle()
                                                    .fill(Color.gray.opacity(0.5))
                                                    .frame(width: 15, height: 15)
                                                
                                                Text("by User")
                                                    .font(.footnote)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                } else {
                                    Spacer()
                                        .frame(width: 150, height: 200)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// SortOptionButton component
struct SortOptionButton: View {
    var label: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(Capsule().stroke(Color.black, lineWidth: 1))
                .foregroundColor(.black)
        }
    }
}

#Preview {
    CommunityView()
}
