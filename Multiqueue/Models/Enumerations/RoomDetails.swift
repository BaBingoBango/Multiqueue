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
    /// The name of the room.
    var name: String
    /// The room's icon.
    var icon: String
    /// The color of the room.
    var color: Color
    /// The description of the room.
    var description: String
    /// The record for this room in CloudKit.
    var record: CKRecord
}
