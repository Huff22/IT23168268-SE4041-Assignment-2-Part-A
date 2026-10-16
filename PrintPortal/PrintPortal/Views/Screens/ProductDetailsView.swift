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
                    // Header Image
                    ZStack(alignment: .topTrailing) {
                        // Product Photo
                        Image(product.imageAssetName)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .strokeBorder(Color(UIColor.separator).opacity(0.35), lineWidth: 0.5)
                            )
                            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                    }
                    .padding(.horizontal)
                    
                    // Title
                    Text(product.rawValue)
                        .font(.title.weight(.bold))
                        .accessibilityAddTraits(.isHeader)
                        .padding(.horizontal)
                    
                    // Details Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Details")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                        
                        Divider()
                        
                        ForEach(product.detailBullets, id: \.self) { bullet in
                            Text(bullet)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineSpacing(3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .printPortalCard(padding: 16)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            
            // Bottom Action Bar
            VStack(spacing: 0) {
                Divider()
                NavigationLink(destination: DesignStudioView(product: product)) {
                    HStack(spacing: 8) {
                        Text("Upload Your Design")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.printPortalAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: Color.printPortalAccent.opacity(0.25), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(DetailsPrimaryButtonStyle())
                .padding(.horizontal)
                .padding(.vertical, 12)
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
                        .foregroundStyle(isFavorite ? Color.printPortalAccent : Color.secondary)
                        .symbolEffect(.bounce, value: isFavorite)
                }
                .accessibilityLabel(isFavorite ? "Remove from favourites" : "Add to favourites")
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

// Subtle press feedback for the bottom action button (navigation still handled by NavigationLink)
private struct DetailsPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
