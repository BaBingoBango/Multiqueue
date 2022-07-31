//
//  Room.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 7/30/22.
//

import Foundation
import CloudKit

/// The basic and CloudKit information making up a Multiqueue room.
struct Room {
    var zone: CKRecordZone
    var details: RoomDetails
    var nowPlayingSong: NowPlayingSong
    var share: CKShare
}
