//
//  FavoriteProduct.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-13.
//
// Models/FavoriteProduct.swift
import Foundation
import SwiftData

@Model
final class FavoriteProduct {
    @Attribute(.unique) var productId: String
    
    init(productId: String) {
        self.productId = productId
    }
}
