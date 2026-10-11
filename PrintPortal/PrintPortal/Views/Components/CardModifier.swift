//
//  CardModifier.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-11.
//

// Views/Components/CardModifier.swift
import SwiftUI

struct PrintPortalCardModifier: ViewModifier {
    var padding: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.printPortalCard)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func printPortalCard(padding: CGFloat = 16) -> some View {
        modifier(PrintPortalCardModifier(padding: padding))
    }
}
