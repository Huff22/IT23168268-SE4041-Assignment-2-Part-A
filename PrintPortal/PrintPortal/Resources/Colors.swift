//
//  Colors.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-11.
//
// Views/Theme/Colors.swift
import SwiftUI

extension Color {
    /// Accent: #761731 (Deep Maroon / Burgundy) in light mode.
    /// Lightened to #B8405E in dark mode so it stays visible on dark surfaces.
    static let printPortalAccent = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0xA8 / 255.0, green: 0x34 / 255.0, blue: 0x4F / 255.0, alpha: 1)
            : UIColor(red: 0x76 / 255.0, green: 0x17 / 255.0, blue: 0x31 / 255.0, alpha: 1)
    })
    
    /// Light mode: system grouped background (unchanged). Dark mode: soft charcoal instead of pure black.
    static let printPortalBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0x12 / 255.0, green: 0x11 / 255.0, blue: 0x13 / 255.0, alpha: 1)
            : UIColor.systemGroupedBackground
    })
    
    /// Light mode: system secondary grouped background (unchanged). Dark mode: slightly lighter charcoal.
    static let printPortalCard = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0x1E / 255.0, green: 0x1C / 255.0, blue: 0x1F / 255.0, alpha: 1)
            : UIColor.secondarySystemGroupedBackground
    })
}
