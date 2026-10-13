// Views/Screens/CatalogueView.swift
import SwiftUI
import SwiftData

struct CatalogueView: View {
    @State private var searchText = ""
    @Query private var favorites: [FavoriteProduct]
    @Environment(\.modelContext) private var modelContext
    
    let allProducts = ProductType.allCases
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var filteredProducts: [ProductType] {
        if searchText.isEmpty { return allProducts }
        return allProducts.filter { $0.rawValue.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search products...", text: $searchText)
                }
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                .padding(.horizontal)
                
                Text("Featured Products")
                    .font(.title3)
                    .bold()
                    .padding(.horizontal)
                
                // 2-Column Grid
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(filteredProducts) { product in
                        NavigationLink(destination: ProductDetailsView(product: product)) {
                            ProductCardView(
                                product: product,
                                isFavorite: favorites.contains(where: { $0.productId == product.rawValue }),
                                onFavoriteToggle: { toggleFavorite(for: product) }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color.printPortalBackground.ignoresSafeArea())
        .navigationTitle("Home")
    }
    
    private func toggleFavorite(for product: ProductType) {
        if let existing = favorites.first(where: { $0.productId == product.rawValue }) {
            modelContext.delete(existing)
        } else {
            let newFav = FavoriteProduct(productId: product.rawValue)
            modelContext.insert(newFav)
        }
    }
}

// Reusable 2-Column Card Component
struct ProductCardView: View {
    let product: ProductType
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image Box
            
                        ZStack(alignment: .topTrailing) {
                            Image(product.imageAssetName)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 120)
                                .frame(maxWidth: .infinity)
                                .clipShape(
                                    // Only round the top corners for the card image
                                    .rect(
                                        topLeadingRadius: 12,
                                        bottomLeadingRadius: 0,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: 12
                                    )
                                )
                                .clipped()
                            
                            
                        }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.rawValue)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(product.availableSizes.first?.display ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 12)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}
