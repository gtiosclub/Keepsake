//
//  CommunityView.swift
//  Keepsake
//
//  Created by Connor on 2/5/25.
//
import SwiftUI

var journals: [Journal] = [
    Journal(name: "Journal 1", createdDate: "2/2/25", entries: [], category: "entry1", isSaved: true, isShared: false, template: Template()),
    Journal(name: "Journal 2", createdDate: "2/3/25", entries: [], category: "entry2", isSaved: true, isShared: true, template: Template()),
    Journal(name: "Journal 3", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template()),
    Journal(name: "Journal 4", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template()),
    Journal(name: "Journal 5", createdDate: "2/4/25", entries: [], category: "entry3", isSaved: false, isShared: false, template: Template()),
    Journal(name: "Journal 6", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template()),
    Journal(name: "Journal 7", createdDate: "2/5/25", entries: [], category: "entry4", isSaved: true, isShared: false, template: Template())
]

var sortOptions: [String] = ["↑↓", "Your Friends", "Travel", "Near You"]

struct CommunityView: View {
    var body: some View {
        ScrollView (.vertical, showsIndicators: false) {
            VStack (alignment: .leading) {
                HStack {
                    Text("Your Community")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .font(.system(size: 25))
                }
        
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
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.5))
                                        .frame(width: 150, height: 200)
                                        .cornerRadius(10)
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
