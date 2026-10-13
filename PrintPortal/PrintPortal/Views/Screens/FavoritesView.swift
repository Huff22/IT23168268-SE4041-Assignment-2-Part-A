//
//  FavoritesView.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-13.
//

// Views/Screens/FavoritesView.swift
import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query private var favorites: [FavoriteProduct]
    
    var favoriteProducts: [ProductType] {
        favorites.compactMap { ProductType(rawValue: $0.productId) }
    }
    
    var body: some View {
        Group {
            if favoriteProducts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.printPortalAccent.opacity(0.7))
                    Text("No Favorites Yet")
                        .font(.headline)
                    Text("Tap the heart on any product to save it here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                List(favoriteProducts) { product in
                    NavigationLink(destination: ProductDetailsView(product: product)) {
                        HStack {
                                                    Image(product.imageAssetName)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 40, height: 40)
                                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                                        .clipped()
                                                    
                                                    Text(product.rawValue)
                                                        .font(.headline)
                                                }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .background(Color.printPortalBackground.ignoresSafeArea())
        .navigationTitle("Favorites")
    }
}
