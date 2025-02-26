//
//  Item.swift
//  TriviaTwist
//
//  Created by Ben Zhou on 2025-02-25.
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
