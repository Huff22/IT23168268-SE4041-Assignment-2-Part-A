//
//  MainTabView.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-11.
//
// Views/Screens/MainTabView.swift
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                CatalogueView()
            }
            .tabItem {
                Label("Catalogue", systemImage: "square.grid.2x2")
            }
            .tag(0)
            
            NavigationStack {
                ProjectsListView()
            }
            .tabItem {
                Label("My Projects", systemImage: "folder")
            }
            .tag(1)
        }
        .tint(.printPortalAccent)
    }
}
