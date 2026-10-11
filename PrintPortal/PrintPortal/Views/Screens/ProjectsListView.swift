//
//  ProjectsListView.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-11.
//
// Views/Screens/ProjectsListView.swift
import SwiftUI
import SwiftData

struct ProjectsListView: View {
    @Query(sort: \DesignProject.lastModifiedAt, order: .reverse) private var projects: [DesignProject]
    
    var body: some View {
        Group {
            if projects.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.printPortalAccent.opacity(0.7))
                    Text("No Projects Yet")
                        .font(.headline)
                    Text("Select a product from the Catalogue to begin your first AR print preview.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            } else {
                List(projects) { project in
                    VStack(alignment: .leading) {
                        Text(project.title)
                            .font(.headline)
                        Text(project.productType.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .background(Color.printPortalBackground.ignoresSafeArea())
        .navigationTitle("My Projects")
    }
}
