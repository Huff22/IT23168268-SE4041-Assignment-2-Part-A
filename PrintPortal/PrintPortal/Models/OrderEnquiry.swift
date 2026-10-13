//
//  OrderEnquiry.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-13.
//
// Models/OrderEnquiry.swift
import Foundation
import SwiftData

@Model
final class OrderEnquiry {
    @Attribute(.unique) var id: UUID
    var projectTitle: String
    var productType: String
    var dimensions: String
    var quantity: Int
    var requirements: String
    var contactDetails: String
    var submittedAt: Date
    
    init(projectTitle: String, productType: String, dimensions: String, quantity: Int, requirements: String, contactDetails: String) {
        self.id = UUID()
        self.projectTitle = projectTitle
        self.productType = productType
        self.dimensions = dimensions
        self.quantity = quantity
        self.requirements = requirements
        self.contactDetails = contactDetails
        self.submittedAt = Date()
    }
}
