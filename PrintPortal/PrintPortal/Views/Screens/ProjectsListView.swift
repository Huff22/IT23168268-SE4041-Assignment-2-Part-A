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
                emptyState
            } else {
                List {
                    ForEach(projects) { project in
                        NavigationLink(destination: ARPreviewView(project: project)) {
                            HStack(spacing: 14) {
                                if let filename = project.artworkFilename,
                                   let uiImage = ArtworkStorageService.shared.loadImage(filename: filename) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 64, height: 64)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .strokeBorder(Color(UIColor.separator).opacity(0.35), lineWidth: 0.5)
                                        )
                                        .accessibilityHidden(true)
                                } else {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color(UIColor.tertiarySystemFill))
                                        .frame(width: 64, height: 64)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .foregroundStyle(.secondary)
                                        )
                                        .accessibilityHidden(true)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(project.title)
                                        .font(.headline)
                                        .lineLimit(1)
                                    Text(project.productType.rawValue)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Text("\(String(format: "%.2f", project.widthMeters))m × \(String(format: "%.2f", project.heightMeters))m")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        .listRowBackground(Color.printPortalCard)
                    }
                    .onDelete(perform: deleteProjects)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .tint(Color.printPortalAccent)
        .background(Color.printPortalBackground.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.25), value: projects.isEmpty)
        .navigationTitle("My Projects")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Presentation-only empty state (matches the Favorites empty state)
    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.printPortalAccent.opacity(0.08))
                    .frame(width: 168, height: 168)
                Circle()
                    .fill(Color.printPortalAccent.opacity(0.12))
                    .frame(width: 124, height: 124)
                Circle()
                    .fill(Color.printPortalAccent)
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.printPortalAccent.opacity(0.3), radius: 12, x: 0, y: 6)
                Image(systemName: "doc.badge.plus")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)
            
            VStack(spacing: 8) {
                Text("No Projects Yet")
                    .font(.title2.weight(.bold))
                    .accessibilityAddTraits(.isHeader)
                
                Text("Select a product from the Catalogue to begin your first AR print preview.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 40)
        .transition(.opacity)
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
