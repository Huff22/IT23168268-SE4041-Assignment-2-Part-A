//
//  CatalogueView.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-11.
//
// Views/Screens/CatalogueView.swift
import SwiftUI

struct CatalogueView: View {
    let products = ProductType.allCases
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(products) { product in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.rawValue)
                            .font(.headline)
                            .foregroundColor(.printPortalAccent)
                        Text(product.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack {
                            Text("Default: \(String(format: "%.0f", product.defaultWidthMeters * 100)) × \(String(format: "%.0f", product.defaultHeightMeters * 100)) cm")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.printPortalAccent)
                        }
                    }
                    .printPortalCard()
                }
            }
            .padding()
        }
        .background(Color.printPortalBackground.ignoresSafeArea())
        .navigationTitle("Print Catalogue")
    }
}
