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
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .tint(Color.printPortalAccent)
        }
        .modelContainer(for: [DesignProject.self, OrderEnquiry.self, FavoriteProduct.self])
    }
}
