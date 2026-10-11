//
//  ProductType.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-11.
//
// Models/ProductType.swift
import Foundation

enum ProductType: String, Codable, CaseIterable, Identifiable {
    case aFrame = "A-Frame Sign"
    case rollupBanner = "Roll-up Banner"
    case rigidBoard = "Rigid Board Sign"
    
    var id: String { rawValue }
    
    var defaultWidthMeters: Float {
        switch self {
        case .aFrame: return 0.60       // 60 cm wide
        case .rollupBanner: return 0.85 // 85 cm wide
        case .rigidBoard: return 0.50   // 50 cm wide
        }
    }
    
    var defaultHeightMeters: Float {
        switch self {
        case .aFrame: return 0.90       // 90 cm high
        case .rollupBanner: return 2.00 // 200 cm high
        case .rigidBoard: return 0.70   // 70 cm high
        }
    }
    
    var description: String {
        switch self {
        case .aFrame:
            return "Pavement sidewalk display with dual printable surfaces."
        case .rollupBanner:
            return "Retractable floor-standing banner with an aluminium cassette."
        case .rigidBoard:
            return "Flat, rigid structural board sign with rear mount support."
        }
    }
}
