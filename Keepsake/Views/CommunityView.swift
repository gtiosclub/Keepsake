//
//  CommunityView.swift
//  Keepsake
//
//  Created by Connor on 2/5/25.
//
import SwiftUI

struct CommunityView: View {
    var body: some View {
        VStack {
            Image(systemName: "person.2")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Community Page")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
