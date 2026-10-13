//
//  Colors.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-11.
//
// Views/Theme/Colors.swift
import SwiftUI

extension Color {
    /// Accent color: #761731 (Deep Maroon / Burgundy) remains the same
    static let printPortalAccent = Color(red: 0x76 / 255.0, green: 0x17 / 255.0, blue: 0x31 / 255.0)
    
    /// Use iOS system grouped backgrounds so they automatically invert in Dark Mode
    static let printPortalBackground = Color(UIColor.systemGroupedBackground)
    static let printPortalCard = Color(UIColor.secondarySystemGroupedBackground)
}
