//
//  TemplateCommunityView.swift
//  Keepsake
//
//  Created by Divya Mathew on 3/5/25.
//

import SwiftUI

    struct TemplateCommunityView: View {
        @State var scaleEffect = 0.4
        @State private var searchText: String = ""
        @State private var selectedJournal: Journal?
        @State private var showDetail = false
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        var body: some View {
            ScrollView (.vertical, showsIndicators: false) {
                VStack (alignment: .center) {
                    HStack {
                        Text("Templates")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding()
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .font(.system(size: 25))
                            .padding(.trailing)
                    
                    }
                    .padding(.horizontal)
                   
                    TextField("Search templates", text: $searchText)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 117).fill(Color.gray.opacity(0.2)))
                        .frame(width: screenWidth * 0.87)
                        .padding(.horizontal)

                    let totalRows = (journals.count / 2) + (journals.count % 2)

                    ForEach(0..<totalRows, id: \.self) { row in
                        // logic because Journals are not currently from db
                        HStack(spacing: 25) {
                            ForEach(0..<2, id: \.self) { column in
                                let index = row * 2 + column
                                if index < journals.count {
                                    let adjustedWidth = screenWidth * 0.92 * scaleEffect
                                    let adjustedHeight = screenHeight * 0.56 * scaleEffect

                                    VStack(alignment: .leading) {
    //                                    Rectangle()
    //                                        .fill(Color.gray.opacity(0.5))
    //                                        .frame(width: 150, height: 200)
    //                                        .cornerRadius(10)
                                        JournalCover(book: journals[index], degrees: 0)
                                            .scaleEffect(scaleEffect)
                                            .frame(width: adjustedWidth, height: adjustedHeight)
                                            .onTapGesture {
                                                selectedJournal = journals [index]
                                                showDetail = true
                                            }
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
            .sheet(isPresented: $showDetail) {
                if let journal = selectedJournal {
                    JournalDetailView(journal: journal)
                }
            }
        }
                   
    }
    struct JournalDetailView: View {
        var journal: Journal
        
        var body: some View {
            VStack(spacing: 20) {
                Text(journal.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                JournalCover(book: journal, degrees: 0)
                    .scaleEffect(0.8) // Make it bigger
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.5)
                
                Text("Description of the template.")
                    .font(.body)
                    .foregroundColor(.gray)
                
                Button(action: {
                    // Handle template selection logic
                }) {
                    Text("Use Template")
                        .padding()
                        .frame(width: 200)
                        .background(RoundedRectangle(cornerRadius: 10).stroke())
                }
                
                Spacer()
            }
            .padding()
        }
    }


    #Preview {
        TemplateCommunityView()
    }
