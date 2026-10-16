//
//  DesignStudioView.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-11.
//

// Views/Screens/DesignStudioView.swift
import SwiftUI
import PhotosUI
import SwiftData

struct DesignStudioView: View {
    @Environment(\.modelContext) private var modelContext
    
    let product: ProductType
    
    // Form State
    @State private var title: String = ""
    @State private var selectedSize: ProductSize?
    
    // Photo Picker State
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var resolutionWarning: Bool = false
    @State private var newlySavedProject: DesignProject? = nil
    @State private var navigateToAR: Bool = false
    @State private var showingSaveError: Bool = false
    
    // Title with leading/trailing spaces and newlines removed
    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var isIncomplete: Bool {
        trimmedTitle.isEmpty || selectedImage == nil || selectedSize == nil
    }
    
    init(product: ProductType) {
        self.product = product
        _selectedSize = State(initialValue: product.availableSizes.first)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Project Details")) {
                TextField("Project Name (e.g. Summer Promo)", text: $title)
                
                if product.availableSizes.isEmpty {
                    LabeledContent("Size", value: "No sizes available")
                } else {
                    Picker("Select Size", selection: $selectedSize) {
                        ForEach(product.availableSizes, id: \.self) { size in
                            Text(size.display).tag(Optional(size))
                        }
                    }
                }
            }
            
            Section(
                header: Text("Artwork"),
                footer: HStack(alignment: .top, spacing: 6) {
                    if resolutionWarning {
                        Image(systemName: "exclamationmark.triangle.fill")
                    }
                    Text(resolutionWarning
                         ? "Warning: Image resolution might be too low for high-quality printing."
                         : "Upload a high-resolution image for best results.")
                }
                .foregroundStyle(resolutionWarning ? Color.red : Color.secondary)
            ) {
                
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Label(selectedImage == nil ? "Select Artwork" : "Change Artwork",
                          systemImage: "photo.badge.plus")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.printPortalAccent)
                }
                .onChange(of: selectedItem) { _, newItem in
                    loadPhoto(from: newItem)
                }
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color(UIColor.separator).opacity(0.35), lineWidth: 0.5)
                        )
                        .padding(.vertical, 8)
                        .transition(.opacity.combined(with: .scale(scale: 0.97)))
                }
            }
            
            Section(
                footer: Group {
                    if isIncomplete {
                        Text(selectedSize == nil
                             ? "This product has no sizes available."
                             : "Add a project name and artwork to continue.")
                    }
                }
            ) {
                Button(action: saveProject) {
                    Text("Save & Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .disabled(isIncomplete)
                .listRowBackground(Color.printPortalAccent.opacity(isIncomplete ? 0.35 : 1))
                .foregroundStyle(.white)
            }
        }
        .tint(Color.printPortalAccent)
        .scrollContentBackground(.hidden)
        .background(Color.printPortalBackground.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.25), value: selectedImage != nil)
        .animation(.easeInOut(duration: 0.2), value: resolutionWarning)
        .navigationTitle("New \(product.rawValue)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToAR) {
            if let project = newlySavedProject {
                ARPreviewView(project: project)
            }
        }
        .alert("Couldn't Save Artwork", isPresented: $showingSaveError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your artwork couldn't be saved to this device. Check your available storage and try again.")
        }
    }
    
    // MARK: - Logic
    
    private func loadPhoto(from item: PhotosPickerItem?) {
        Task {
            if let data = try? await item?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.selectedImage = uiImage
                    checkResolution(image: uiImage)
                }
            }
        }
    }
    
    private func checkResolution(image: UIImage) {
        // Basic check: If width or height is less than 1000 pixels, warn the user
        if image.size.width < 1000 || image.size.height < 1000 {
            resolutionWarning = true
        } else {
            resolutionWarning = false
        }
    }
    
    private func saveProject() {
        guard let image = selectedImage, let size = selectedSize else { return }
        
        let newProjectId = UUID()
        let savedFilename: String
        
        do {
            savedFilename = try ArtworkStorageService.shared.saveImage(image, id: newProjectId)
        } catch {
            // Don't create a project without artwork; tell the user instead
            print("Failed to save image to disk: \(error)")
            showingSaveError = true
            return
        }
        
        let newProject = DesignProject(
            title: trimmedTitle,
            productType: product,
            widthMeters: size.widthMeters,
            heightMeters: size.heightMeters,
            artworkFilename: savedFilename
        )
        newProject.id = newProjectId
        
        // Save to SwiftData
        modelContext.insert(newProject)
        
        // Trigger the automatic navigation to the AR Screen
        self.newlySavedProject = newProject
        self.navigateToAR = true
    }
}
