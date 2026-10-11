//
//  ArtworkStorageService.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-11.
//
// Services/Persistence/ArtworkStorageService.swift
import UIKit

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
}
