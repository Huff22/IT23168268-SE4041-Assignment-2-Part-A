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
                emptyState
            } else {
                List(favoriteProducts) { product in
                    NavigationLink(destination: ProductDetailsView(product: product)) {
                        HStack(spacing: 14) {
                            Image(product.imageAssetName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(Color(UIColor.separator).opacity(0.35), lineWidth: 0.5)
                                )
                                .accessibilityHidden(true)
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(product.rawValue)
                                    .font(.headline)
                                
                                if let size = product.availableSizes.first?.display {
                                    Text(size)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .listRowBackground(Color.printPortalCard)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .tint(Color.printPortalAccent)
        .background(Color.printPortalBackground.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.25), value: favoriteProducts.isEmpty)
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Presentation-only empty state
    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.printPortalAccent.opacity(0.08))
                    .frame(width: 168, height: 168)
                Circle()
                    .fill(Color.printPortalAccent.opacity(0.12))
                    .frame(width: 124, height: 124)
                Circle()
                    .fill(Color.printPortalAccent)
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.printPortalAccent.opacity(0.3), radius: 12, x: 0, y: 6)
                Image(systemName: "heart.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)
            
            VStack(spacing: 8) {
                Text("No Favorites Yet")
                    .font(.title2.weight(.bold))
                    .accessibilityAddTraits(.isHeader)
                
                Text("Tap the heart on any product to save it here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 40)
        .transition(.opacity)
    }
}
