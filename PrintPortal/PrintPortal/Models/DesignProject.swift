//
//  DesignProject.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-11.
//
// Models/DesignProject.swift
import Foundation
import SwiftData

@Model
final class DesignProject {
    @Attribute(.unique) var id: UUID
    var title: String
    var productTypeRaw: String
    var widthMeters: Float
    var heightMeters: Float
    var artworkFilename: String?
    var createdAt: Date
    var lastModifiedAt: Date
    
    // Placement metadata persisted for AR session restoration
    var savedAnchorX: Float?
    var savedAnchorY: Float?
    var savedAnchorZ: Float?
    var savedRotationY: Float?
    
    var productType: ProductType {
        get { ProductType(rawValue: productTypeRaw) ?? .aFrame }
        set { productTypeRaw = newValue.rawValue }
    }
    
    init(
        title: String,
        productType: ProductType,
        widthMeters: Float? = nil,
        heightMeters: Float? = nil,
        artworkFilename: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.productTypeRaw = productType.rawValue
        self.widthMeters = widthMeters ?? productType.defaultWidthMeters
        self.heightMeters = heightMeters ?? productType.defaultHeightMeters
        self.artworkFilename = artworkFilename
        self.createdAt = Date()
        self.lastModifiedAt = Date()
    }
}
