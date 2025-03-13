//
//  SwiftUIView.swift
//  Keepsake
//
//  Created by Divya Mathew on 3/11/25.
//

import SwiftUI

struct TemplateCommunityView: View {
    @State var scaleEffect = 0.4
    @State private var searchText: String = ""
    @State private var selectedTemplate: Int? = nil
    @State private var showDetail = false
    @State var templates: [Template]

    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height

    // Precompute total rows to avoid heavy calculations inside ForEach
    var totalRows: Int {
        (templates.count / 2) + (templates.count % 2)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center) {
                // HEADER
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

                // SEARCH FIELD
                TextField("Search templates", text: $searchText)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
                    .frame(width: screenWidth * 0.87)
                    .padding(.horizontal)

                // JOURNALS GRID
                ForEach(0..<totalRows, id: \.self) { row in
                    HStack(spacing: 25) {
                        ForEach(0..<2, id: \.self) { column in
                            let index = row * 2 + column
                            if index < templates.count {
                                JournalItemView(
                                    template: templates[index],
                                    scaleEffect: scaleEffect,
                                    screenWidth: screenWidth,
                                    screenHeight: screenHeight
                                )
                                .onTapGesture {
                                    selectedTemplate = index
                                    showDetail = true
                                }
                            } else {
                                Spacer().frame(width: 150, height: 200)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { selectedTemplate != nil },
            set: { if !$0 { selectedTemplate = nil } }
        )) {
            if let index = selectedTemplate {
                JournalDetailView(template: templates[index])
            }
        }
    }
}

// EXTRACTED JOURNAL ITEM VIEW (Fixes Compiler Struggles)
struct JournalItemView: View {
    @State var template: Template
    let scaleEffect: CGFloat
    let screenWidth: CGFloat
    let screenHeight: CGFloat

    var body: some View {
        let adjustedWidth = screenWidth * 0.92 * scaleEffect
        let adjustedHeight = screenHeight * 0.56 * scaleEffect

        VStack(alignment: .leading) {
            JournalCover(template: template, degrees: 0, title: template.name)
                .scaleEffect(scaleEffect)
                .frame(width: adjustedWidth, height: adjustedHeight)

            VStack(alignment: .leading, spacing: 3) {
                Text(template.name)
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
    }
}

// JOURNAL DETAIL VIEW
struct JournalDetailView: View {
    @State var template: Template
    @Environment(\.dismiss) var dismiss
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .padding()
                    .foregroundColor(.blue)
                }
                
                Spacer()
            }
            ZStack{
                Text(template.name)
                    .font(.title)
                    .fontWeight(.bold)
            }
                    .frame(maxWidth: .infinity, alignment: .center)
            
            JournalCover(template: template, degrees: 0, title: template.name)
                .scaleEffect(0.8)
                .frame(width: screenWidth * 0.8, height: screenHeight * 0.5)

            Text("Description of the template.")
                .font(.body)
                .foregroundColor(.gray)

            Button(action: {
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
    TemplateCommunityView(templates: [Template(coverColor: .red, pageColor: .white, titleColor: .black), Template(coverColor: .blue, pageColor: .white, titleColor: .black), Template(coverColor: .green, pageColor: .white, titleColor: .black)])
}

