//
//  ArtworkStorageService.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-11.
//
// Services/Persistence/ArtworkStorageService.swift
import UIKit
import ARKit

final class ArtworkStorageService {
    static let shared = ArtworkStorageService()
    private init() {}
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func saveImage(_ image: UIImage, id: UUID) throws -> String {
        let filename = "\(id.uuidString).png"
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        guard let data = image.pngData() else {
            throw NSError(domain: "ArtworkStorage", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to PNG"])
        }
        
        try data.write(to: fileURL)
        return filename
    }
    
    func loadImage(filename: String) -> UIImage? {
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    func deleteImage(filename: String) {
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    // MARK: - ARWorldMap Persistence
        
        func saveWorldMap(_ worldMap: ARWorldMap, id: UUID) throws {
            // Securely encode the complex 3D room data into a binary format
            let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
            let fileURL = documentsDirectory.appendingPathComponent("\(id.uuidString)_worldmap.data")
            try data.write(to: fileURL)
        }
        
        func loadWorldMap(id: UUID) -> ARWorldMap? {
            let fileURL = documentsDirectory.appendingPathComponent("\(id.uuidString)_worldmap.data")
            guard let data = try? Data(contentsOf: fileURL) else { return nil }
            
            // Decode the binary data back into an ARKit World Map
            return try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
        }
}
