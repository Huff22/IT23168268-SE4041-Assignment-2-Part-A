//
//  Item.swift
//  PrintPortal
//
//  Created by Hafsa Faleel on 2026-10-11.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
