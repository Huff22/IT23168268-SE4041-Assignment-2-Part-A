import SwiftUI
import RealityKit
import ARKit

enum ARUIState {
    case scanning
    case readyToPlace
    case placed
}

struct ARViewContainer: UIViewRepresentable {
    let project: DesignProject
    let artworkImage: UIImage
    @Binding var arState: ARUIState
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        
        // Start a fresh AR session every time
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        arView.session.delegate = context.coordinator
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGesture)
        context.coordinator.arView = arView
        
        // Listen for Snapshot trigger ONLY
        NotificationCenter.default.addObserver(forName: Notification.Name("TakeARSnapshot"), object: nil, queue: .main) { _ in
            arView.snapshot(saveToHDR: false) { image in
                guard let image = image else { return }
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                
                // Haptic feedback for the photo
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        weak var arView: ARView?
        var isModelPlaced = false
        var productEntity: ModelEntity?
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = arView, !isModelPlaced else { return }
            
            let tapLocation = sender.location(in: arView)
            let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
            
            if let firstResult = results.first {
                let anchor = ARAnchor(name: "PrintPortalSign", transform: firstResult.worldTransform)
                arView.session.add(anchor: anchor)
                isModelPlaced = true
            }
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if anchor is ARPlaneAnchor, parent.arState == .scanning {
                    DispatchQueue.main.async { self.parent.arState = .readyToPlace }
                } else if anchor.name == "PrintPortalSign" {
                    if self.productEntity == nil {
                        placeSignModel(on: anchor)
                        DispatchQueue.main.async { self.parent.arState = .placed }
                    }
                }
            }
        }
        
        func placeSignModel(on arAnchor: ARAnchor) {
            guard let arView = arView else { return }
            
            let anchorEntity = AnchorEntity(anchor: arAnchor)
            let safeImage = parent.artworkImage.normalizedForRealityKit() ?? parent.artworkImage
            
            guard let productEntity = createProductEntity(for: parent.project) else {
                print("Error: Could not create the USDZ entity.")
                return
            }
            self.productEntity = productEntity
            
            if let cgImage = safeImage.cgImage {
                do {
                    let texture = try TextureResource(image: cgImage, options: .init(semantic: .color))
                    var customMaterial = SimpleMaterial(color: .white, isMetallic: false)
                    customMaterial.color = .init(tint: .white, texture: .init(texture))
                    
                    let targetEntity: ModelEntity? = productEntity.model != nil ? productEntity : productEntity.children.compactMap { $0 as? ModelEntity }.first(where: { $0.model != nil })
                    
                    if let target = targetEntity, var modelComp = target.model {
                        var materials = modelComp.materials
                        
                        if let canvasIndex = materials.firstIndex(where: { $0.name?.lowercased().contains("canvas") == true }) {
                            materials[canvasIndex] = customMaterial
                        } else if materials.count > 1 {
                            materials[1] = customMaterial
                        } else if materials.count > 0 {
                            materials[0] = customMaterial
                        }
                        
                        modelComp.materials = materials
                        target.model = modelComp
                    }
                } catch {
                    print("Failed to generate texture: \(error)")
                }
            }
            
            arView.installGestures([.translation, .rotation], for: productEntity)
            anchorEntity.addChild(productEntity)
            arView.scene.addAnchor(anchorEntity)
        }
        
        private func createProductEntity(for project: DesignProject) -> ModelEntity? {
            let modelName: String
            let baseWidth: Float
            let baseHeight: Float
            
            switch project.productType {
            case .aFrame:
                modelName = "AFrameSign"
                baseWidth = 0.46
                baseHeight = 0.61
            case .rollupBanner:
                modelName = "RollupBanner"
                baseWidth = 0.84
                baseHeight = 2.06
            case .rigidBoard:
                modelName = "RigidBoard"
                baseWidth = 0.30
                baseHeight = 0.46
            }
            
            guard let entity = try? ModelEntity.loadModel(named: modelName) else {
                print("❌ Failed to load \(modelName).usdz from Resources!")
                return nil
            }
            
            let scaleX = project.widthMeters / baseWidth
            let scaleY = project.heightMeters / baseHeight
            entity.scale = [scaleX, scaleY, scaleX]
            
            entity.generateCollisionShapes(recursive: true)
            return entity
        }
    }
}

extension UIImage {
    func normalizedForRealityKit() -> UIImage? {
        let maxDimension: CGFloat = 1024
        var targetSize = self.size
        
        if size.width > maxDimension || size.height > maxDimension {
            let ratio = size.width / size.height
            if ratio > 1 {
                targetSize = CGSize(width: maxDimension, height: maxDimension / ratio)
            } else {
                targetSize = CGSize(width: maxDimension * ratio, height: maxDimension)
            }
        }
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
