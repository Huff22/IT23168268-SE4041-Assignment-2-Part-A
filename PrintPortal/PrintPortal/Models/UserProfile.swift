//
//  UserProfile.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-13.
//
// Models/UserProfile.swift
import Foundation
import SwiftData

@Model
final class UserProfile {
    var fullName: String
    var username: String
    var email: String
    var homeAddress: String
    var createdAt: Date
    
    init(fullName: String, username: String, email: String, homeAddress: String) {
        self.fullName = fullName
        self.username = username
        self.email = email
        self.homeAddress = homeAddress
        self.createdAt = Date()
    }
}
