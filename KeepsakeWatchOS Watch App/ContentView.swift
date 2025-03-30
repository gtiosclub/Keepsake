//
//  ContentView.swift
//  KeepsakeWatchOS Watch App
//
//  Created by Nitya Potti on 3/29/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var remindersViewModel: RemindersViewModel
    var body: some View {
        
        VStack {
            Text("Keepsake")
            Image(systemName: "Logo")
                .imageScale(.large)
                .foregroundStyle(.tint)
            NavigationLink(
                destination: RemindersListView()
                    .environmentObject(remindersViewModel),
                label: {
                        
                        font(.title)
                        padding()
                        shadow(radius: 10)
                        cornerRadius(10)
                }
            )
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
