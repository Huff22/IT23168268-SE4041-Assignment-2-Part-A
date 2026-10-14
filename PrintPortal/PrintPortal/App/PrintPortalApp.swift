//
//  PrintPortalApp.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-11.
//
// App/PrintPortalApp.swift
import SwiftUI
import SwiftData

@main
struct PrintPortalApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                MainTabView()
                    .tint(Color.printPortalAccent)
            } else {
                OnboardingView()
                    .tint(Color.printPortalAccent)
            }
        }
        .modelContainer(for: [DesignProject.self, OrderEnquiry.self, FavoriteProduct.self, UserProfile.self])
    }
}
