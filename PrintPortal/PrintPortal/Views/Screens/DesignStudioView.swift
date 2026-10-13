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
    @Environment(\.dismiss) private var dismiss
    
    let product: ProductType
    
    // Form State
    @State private var title: String = ""
    @State private var selectedSize: ProductSize
    
    // Photo Picker State
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var resolutionWarning: Bool = false
    @State private var newlySavedProject: DesignProject? = nil
    @State private var navigateToAR: Bool = false
    
    init(product: ProductType) {
        self.product = product
        _selectedSize = State(initialValue: product.availableSizes.first!)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Project Details")) {
                            TextField("Project Name (e.g. Summer Promo)", text: $title)
                            
                            Picker("Select Size", selection: $selectedSize) {
                                ForEach(product.availableSizes, id: \.self) { size in
                                    Text(size.display).tag(size)
                                }
                            }
            }
            
            Section(header: Text("Artwork"), footer: Text(resolutionWarning ? "Warning: Image resolution might be too low for high-quality printing." : "Upload a high-resolution image for best results.")
                        .foregroundColor(resolutionWarning ? .red : .secondary)) {
                
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                        Text(selectedImage == nil ? "Select Artwork" : "Change Artwork")
                    }
                    .foregroundColor(.printPortalAccent)
                }
                .onChange(of: selectedItem) { _, newItem in
                    loadPhoto(from: newItem)
                }
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.vertical, 8)
                }
            }
            
            Section {
                Button(action: saveProject) {
                    Text("Save & Continue to AR Preview")
                        .frame(maxWidth: .infinity)
                        .bold()
                }
                .disabled(title.isEmpty || selectedImage == nil)
                .listRowBackground(title.isEmpty || selectedImage == nil ? Color.gray.opacity(0.3) : Color.printPortalAccent)
                .foregroundColor(.white)
            }
        }
        .navigationTitle("New \(product.rawValue)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToAR) {
                    if let project = newlySavedProject {
                        ARPreviewView(project: project)
                    }
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
            guard let image = selectedImage else { return }
            
            let newProjectId = UUID()
            var savedFilename: String? = nil
            
            do {
                savedFilename = try ArtworkStorageService.shared.saveImage(image, id: newProjectId)
            } catch {
                print("Failed to save image to disk: \(error)")
            }
            
            let newProject = DesignProject(
                    title: title,
                    productType: product,
                    widthMeters: selectedSize.widthMeters,
                    heightMeters: selectedSize.heightMeters,
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
