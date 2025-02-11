//
//  HomeView.swift
//  Keepsake
//
//  Created by Connor on 2/5/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Image(systemName: "house")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Home Page")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
