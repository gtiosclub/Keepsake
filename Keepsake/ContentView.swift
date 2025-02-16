//
//  ContentView.swift
//  Keepsake
//
//  Created by Rik Roy on 2/2/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomepageView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            CommunityView()
                .tabItem {
                    Label("Community", systemImage: "person.2")
                }
            ScrapbookView()
                .tabItem {
                    Label("Scrapbooks", systemImage: "ellipsis.viewfinder")
                }
            
        }.onAppear {
            // correct the transparency bug for Tab bars
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            // correct the transparency bug for Navigation bars
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }
        .tint(Color.blue)
    }
}

#Preview {
    ContentView()
}
