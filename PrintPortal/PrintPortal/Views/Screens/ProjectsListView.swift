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
    @Environment(\.modelContext) private var modelContext
    
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
                List {
                    ForEach(projects) { project in
                        NavigationLink(destination: ARPreviewView(project: project)) {
                            HStack(spacing: 16) {
                                if let filename = project.artworkFilename,
                                   let uiImage = ArtworkStorageService.shared.loadImage(filename: filename) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                        .overlay(Image(systemName: "photo").foregroundColor(.gray))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(project.title)
                                        .font(.headline)
                                    Text(project.productType.rawValue)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("\(String(format: "%.2f", project.widthMeters))m × \(String(format: "%.2f", project.heightMeters))m")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deleteProjects)
                }
            }
        }
        .background(Color.printPortalBackground.ignoresSafeArea())
        .navigationTitle("My Projects")
    }
    
    private func deleteProjects(offsets: IndexSet) {
        for index in offsets {
            let project = projects[index]
            
            // 1. Delete the heavy image file from disk storage to free up space
            if let filename = project.artworkFilename {
                ArtworkStorageService.shared.deleteImage(filename: filename)
            }
            
            // 2. Delete the metadata record from the SwiftData database
            modelContext.delete(project)
        }
    }
}
