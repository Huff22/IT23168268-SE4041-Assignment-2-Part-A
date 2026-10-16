//
//  ProductDetailsView.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-13.
//
// Views/Screens/ProductDetailsView.swift
import SwiftUI
import SwiftData

struct ProductDetailsView: View {
    let product: ProductType
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var favorites: [FavoriteProduct]
    
    var isFavorite: Bool {
        favorites.contains(where: { $0.productId == product.rawValue })
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Image Placeholder
                    ZStack(alignment: .topTrailing) {
                                            // Product Photo
                                            Image(product.imageAssetName)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 250)
                                                .frame(maxWidth: .infinity)
                                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                                .clipped()
                                            
                                            
                                        }
                                        .padding(.horizontal)
                    
                    // Title
                    Text(product.rawValue)
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    // Details Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Details")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        ForEach(product.detailBullets, id: \.self) { bullet in
                            Text(bullet)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            
            // Bottom Action Bar
            VStack {
                Divider()
                NavigationLink(destination: DesignStudioView(product: product)) {
                    Text("Upload Your Design")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.printPortalAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
            .background(Color.printPortalBackground)
        }
        .background(Color.printPortalBackground.ignoresSafeArea())
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: toggleFavorite) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.headline)
                                .foregroundColor(isFavorite ? .printPortalAccent : .gray)
                        }
                    }
                }
    }
    
    private func toggleFavorite() {
        if let existing = favorites.first(where: { $0.productId == product.rawValue }) {
            modelContext.delete(existing)
        } else {
            let newFavorite = FavoriteProduct(productId: product.rawValue)
            modelContext.insert(newFavorite)
        }
    }
}
