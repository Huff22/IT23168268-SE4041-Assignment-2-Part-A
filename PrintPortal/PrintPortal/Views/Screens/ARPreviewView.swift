// Views/Screens/ARPreviewView.swift
import SwiftUI
import SwiftData

struct ARPreviewView: View {
    let project: DesignProject
    @State private var uiImage: UIImage? = nil
    @State private var arState: ARUIState = .scanning
    @State private var showFlash = false
    @Environment(\.dismiss) private var dismiss // Used for our custom back button
    @State private var showingQuoteForm = false
    @Query private var profiles: [UserProfile]
    @State private var showingAccountPrompt = false
    
    var body: some View {
        ZStack {
            if let uiImage = uiImage {
                // AR Camera filling the whole screen
                ARViewContainer(project: project, artworkImage: uiImage, arState: $arState)
                    .ignoresSafeArea()
                
                // Dimmed background overlay while scanning (fades in/out, still blocks touches only while scanning)
                Color.black.opacity(arState == .scanning ? 0.65 : 0)
                    .ignoresSafeArea()
                    .allowsHitTesting(arState == .scanning)
                    .animation(.easeInOut(duration: 0.3), value: arState)
                
                VStack {
                    // Custom Top Navigation Bar
                    ZStack {
                        // Centered Pill Title
                        VStack(spacing: 2) {
                            Text("Previewing")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.secondary)
                            Text(project.title)
                                .font(.headline.weight(.semibold))
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(Capsule().strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5))
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 3)
                        // Keeps long titles clear of the back button
                        .padding(.horizontal, 56)
                        
                        // Left & Right Buttons
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .font(.title3.bold())
                                    .foregroundStyle(.primary)
                                    .frame(width: 44, height: 44)
                                    .background(.ultraThinMaterial, in: Circle())
                                    .overlay(Circle().strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5))
                                    .shadow(color: .black.opacity(0.15), radius: 8, y: 3)
                            }
                            .buttonStyle(ARCircleButtonStyle())
                            .accessibilityLabel("Back")
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Centered Dynamic Instructions (Scanning/Detected)
                    if arState == .scanning {
                        VStack(spacing: 16) {
                            ProgressView().controlSize(.large).tint(.white)
                            Text("Scanning floor...\nMove your phone slightly.")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                        }
                        .padding(24)
                        .background(Color.black.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5)
                        )
                        .padding(.horizontal, 32)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    } else if arState == .readyToPlace {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                            Text("Floor detected!\nTap to place your \(project.productType.rawValue).")
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.black.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
                        .padding(.horizontal, 32)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                    
                    Spacer()
                    
                    // Bottom Action Bar (Camera & Quote)
                    if arState == .placed {
                        ZStack {
                            // Camera Button (Bottom Middle)
                            Button(action: takeSnapshot) {
                                ZStack {
                                    Circle().fill(Color.white.opacity(0.8)).frame(width: 70, height: 70)
                                    Circle().stroke(Color.white, lineWidth: 4).frame(width: 80, height: 80)
                                    Image(systemName: "camera.fill").font(.title).foregroundStyle(.black)
                                }
                                .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
                            }
                            .buttonStyle(ARCircleButtonStyle())
                            .accessibilityLabel("Take photo")
                            
                            // Request Quote Button (Bottom Right)
                            HStack {
                                Spacer()
                                Button(action: {
                                    if profiles.isEmpty {
                                        showingAccountPrompt = true
                                    } else {
                                        showingQuoteForm = true
                                    }
                                }) {
                                    ZStack {
                                        Circle().fill(Color.printPortalAccent).frame(width: 60, height: 60)
                                        Circle().strokeBorder(Color.white.opacity(0.25), lineWidth: 1).frame(width: 60, height: 60)
                                        Image(systemName: "paperplane.fill").font(.title3).foregroundStyle(.white)
                                    }
                                    .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
                                }
                                .buttonStyle(ARCircleButtonStyle())
                                .accessibilityLabel("Request quote")
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: arState)
                
                // Screen flash effect for the camera
                if showFlash {
                    Color.white.ignoresSafeArea()
                        .transition(.opacity)
                }
                
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                        .controlSize(.large)
                    Text("Loading Artwork...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.printPortalBackground.ignoresSafeArea())
            }
        }
        .sheet(isPresented: $showingQuoteForm) {
            RequestQuoteView(project: project, artworkImage: uiImage)
        }
        .sheet(isPresented: $showingAccountPrompt) {
            NavigationStack {
                ProfileView()
            }
        }
        .toolbar(.hidden, for: .navigationBar) // Hides the default iOS navigation bar
        .toolbar(.hidden, for: .tabBar)
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

// Subtle press feedback for the round overlay buttons (actions unchanged)
private struct ARCircleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
