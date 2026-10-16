// Views/Screens/CatalogueView.swift
import SwiftUI
import SwiftData

struct CatalogueView: View {
    @State private var searchText = ""
    @Query private var favorites: [FavoriteProduct]
    @Environment(\.modelContext) private var modelContext
    
    let allProducts = ProductType.allCases
    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    
    var filteredProducts: [ProductType] {
        if searchText.isEmpty { return allProducts }
        return allProducts.filter { $0.rawValue.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Custom Logo Header
                Image("AppNameLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                // Search Bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search products...", text: $searchText)
                }
                .printPortalCard(padding: 12, cornerRadius: 12)
                .padding(.horizontal)
                
                Text("Featured Products")
                    .font(.title3.weight(.semibold))
                    .accessibilityAddTraits(.isHeader)
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
                        .buttonStyle(ProductCardButtonStyle())
                    }
                }
                .padding(.horizontal)
                .animation(.easeInOut(duration: 0.2), value: searchText)
                
                // Empty state when a search matches nothing
                if filteredProducts.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                        .padding(.top, 24)
                }
            }
            .padding(.vertical)
        }
        .background(Color.printPortalBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
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

// Subtle press feedback for tappable cards (navigation still handled by NavigationLink)
private struct ProductCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// Reusable 2-Column Card Component
struct ProductCardView: View {
    let product: ProductType
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Box
            ZStack(alignment: .topTrailing) {
                Image(product.imageAssetName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 130)
                    .clipped()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.rawValue)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(product.availableSizes.first?.display ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
        // Shared card style; it also clips the image to the rounded top corners
        .printPortalCard(padding: 0, cornerRadius: 14)
    }
}
