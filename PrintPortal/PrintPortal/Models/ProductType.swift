//
//  ProductType.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-11.
//
// Models/ProductType.swift
// Models/ProductType.swift
import Foundation

struct ProductSize: Hashable {
    let widthInches: Float
    let heightInches: Float
    
    var display: String { "\(Int(widthInches))\" × \(Int(heightInches))\"" }
    var widthMeters: Float { widthInches * 0.0254 }
    var heightMeters: Float { heightInches * 0.0254 }
}

enum ProductType: String, Codable, CaseIterable, Identifiable {
    case aFrame = "A-Frame Sign"
    case rollupBanner = "Roll-up Banner"
    case rigidBoard = "Rigid Board Sign"
    
    var id: String { rawValue }
    
    var availableSizes: [ProductSize] {
        switch self {
        case .aFrame:
            return [ProductSize(widthInches: 18, heightInches: 24),
                    ProductSize(widthInches: 24, heightInches: 36)]
        case .rollupBanner:
            return [ProductSize(widthInches: 33, heightInches: 81)]
        case .rigidBoard:
            return [ProductSize(widthInches: 12, heightInches: 18),
                    ProductSize(widthInches: 18, heightInches: 24)]
        }
    }
    
    // We keep these defaults for fallback safety
    var defaultWidthMeters: Float { availableSizes.first!.widthMeters }
    var defaultHeightMeters: Float { availableSizes.first!.heightMeters }
    
    var description: String {
        switch self {
        case .aFrame: return "Pavement sidewalk display with dual printable surfaces."
        case .rollupBanner: return "Retractable floor-standing banner with an aluminium cassette."
        case .rigidBoard: return "Flat, rigid structural board sign with rear mount support."
        }
    }
    
    // UI Assets and Details
        var iconSystemName: String {
            switch self {
            case .aFrame: return "signpost.right.and.left.fill"
            case .rollupBanner: return "scroll.fill"
            case .rigidBoard: return "rectangle.portrait.fill"
            }
        }
    
    // The exact name of the image in Assets.xcassets
        var imageAssetName: String {
            switch self {
            case .aFrame: return "aframe_img"
            case .rollupBanner: return "rollup_img"
            case .rigidBoard: return "rigid_img"
            }
        }
    
        var detailBullets: [String] {
            var bullets = [String]()
            bullets.append(self.description)
            bullets.append("Available sizes:")
            for size in availableSizes {
                bullets.append("• \(size.display) (\(String(format: "%.2f", size.widthMeters))m × \(String(format: "%.2f", size.heightMeters))m)")
            }
            bullets.append("• Full-color UV resistant printing")
            bullets.append("• Indoor and outdoor durable")
            return bullets
        }
}
