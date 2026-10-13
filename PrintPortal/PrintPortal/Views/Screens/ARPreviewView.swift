// Views/Screens/ARPreviewView.swift
import SwiftUI

struct ARPreviewView: View {
    let project: DesignProject
    @State private var uiImage: UIImage? = nil
    @State private var arState: ARUIState = .scanning
    @State private var showFlash = false
    @Environment(\.dismiss) private var dismiss // Used for our custom back button
    
    var body: some View {
        ZStack {
            if let uiImage = uiImage {
                // AR Camera filling the whole screen
                ARViewContainer(project: project, artworkImage: uiImage, arState: $arState)
                    .ignoresSafeArea()
                
                // Dimmed background overlay while scanning
                if arState == .scanning {
                    Color.black.opacity(0.65).ignoresSafeArea()
                }
                
                VStack {
                    // Custom Top Navigation Bar
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        // Pill Shaped Title
                        VStack(spacing: 2) {
                            Text("Previewing")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(project.title)
                                .font(.headline)
                                .bold()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        
                        Spacer()
                        
                        // Invisible spacer to keep the title perfectly centered
                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Centered Dynamic Instructions
                    if arState == .scanning {
                        VStack(spacing: 16) {
                            ProgressView()
                                .controlSize(.large)
                                .tint(.white)
                            Text("Scanning floor...\nMove your phone slightly.")
                                .font(.headline)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .padding(24)
                        .background(Color.black.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                    } else if arState == .readyToPlace {
                        Text("Floor detected!\nTap to place your \(project.productType.rawValue).")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.green.opacity(0.9))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 10)
                    }
                    
                    Spacer()
                    
                    // Camera Capture Button (Only shows when placed)
                    if arState == .placed {
                        Button(action: takeSnapshot) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: 70, height: 70)
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .frame(width: 80, height: 80)
                                Image(systemName: "camera.fill")
                                    .font(.title)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
                
                // Screen flash effect for the camera
                if showFlash {
                    Color.white.ignoresSafeArea()
                        .transition(.opacity)
                }
                
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading Artwork...")
                        .foregroundColor(.secondary)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar) // Hides the default iOS navigation bar
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        if let filename = project.artworkFilename {
            self.uiImage = ArtworkStorageService.shared.loadImage(filename: filename)
        }
    }
    
    private func takeSnapshot() {
        withAnimation(.easeOut(duration: 0.1)) { showFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeIn(duration: 0.2)) { showFlash = false }
        }
        NotificationCenter.default.post(name: Notification.Name("TakeARSnapshot"), object: nil)
    }
}
