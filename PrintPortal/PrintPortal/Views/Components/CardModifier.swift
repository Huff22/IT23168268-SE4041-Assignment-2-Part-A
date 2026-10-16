//
//  CardModifier.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-11.
//

import SwiftUI

struct PrintPortalCardModifier: ViewModifier {
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 16

    @Environment(\.colorScheme) private var colorScheme

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.printPortalCard, in: shape)
            .clipShape(shape)
            // Hairline edge. The system separator colour adapts to light/dark
            // mode, so the card stays defined on similar backgrounds.
            .overlay(
                shape.strokeBorder(Color(UIColor.separator).opacity(colorScheme == .dark ? 0.5 : 0.35),
                                   lineWidth: 0.5)
            )
            // Two-layer shadow for soft, natural depth. Shadows barely show on
            // dark backgrounds, so they are reduced there and the border does the work.
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.0 : 0.05),
                    radius: 12, x: 0, y: 6)
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.0 : 0.03),
                    radius: 2, x: 0, y: 1)
    }
}

extension View {
    func printPortalCard(padding: CGFloat = 16, cornerRadius: CGFloat = 16) -> some View {
        modifier(PrintPortalCardModifier(padding: padding, cornerRadius: cornerRadius))
    }
}
