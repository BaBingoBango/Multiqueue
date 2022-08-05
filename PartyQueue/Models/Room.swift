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
    var ID = UUID()
    var isActive: Bool
    var zone: CKRecordZone
    var details: RoomDetails
    var nowPlayingSong: NowPlayingSong
    var share: CKShare
    var selectedPlayType = PlayType.next
    var queueSongs: [QueueSong] = []
    var songLimit: Int
    var songLimitAction: LimitExpirationAction
    var timeLimit: Int
    var timeLimitAction: LimitExpirationAction
}
