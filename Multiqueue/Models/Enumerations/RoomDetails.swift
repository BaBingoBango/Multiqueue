//
//  RoomDetails.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 7/29/22.
//

import Foundation
import SwiftUI
import CloudKit

/// The information that describes the customization for a Multiqueue room.
struct RoomDetails {
    var name: String
    var icon: String
    var color: Color
    var description: String
    var record: CKRecord
}
