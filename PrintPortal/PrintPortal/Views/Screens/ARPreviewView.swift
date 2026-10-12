//
//  ARPreviewView.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-11.
//

// Views/Screens/ARPreviewView.swift
import SwiftUI

struct ARPreviewView: View {
    let project: DesignProject
    @State private var uiImage: UIImage? = nil
    
    var body: some View {
        ZStack {
            if let uiImage = uiImage {
                ARViewContainer(project: project, artworkImage: uiImage)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    // Instruction Overlay
                    Text("Scan the floor and tap to place your \(project.productType.rawValue). You can drag to move it.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()
                }
            } else {
                VStack {
                    ProgressView()
                    Text("Loading Artwork...")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle(project.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        if let filename = project.artworkFilename {
            self.uiImage = ArtworkStorageService.shared.loadImage(filename: filename)
        }
    }
}
