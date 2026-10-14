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
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            NavigationStack {
                FavoritesView()
            }
            .tabItem {
                Label("Favorites", systemImage: "heart.fill")
            }
            .tag(1)
            
            NavigationStack {
                ProjectsListView()
            }
            .tabItem {
                Label("My Projects", systemImage: "folder.fill")
            }
            .tag(2)
            
            NavigationStack {
                            ProfileView()
                        }
                        .tabItem {
                            Label("Profile", systemImage: "person.crop.circle")
                        }
                        .tag(3)
        }
        .tint(.printPortalAccent)
    }
}
