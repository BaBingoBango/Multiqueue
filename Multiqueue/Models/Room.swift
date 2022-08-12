//
//  Room.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 7/30/22.
//

import Foundation
import CloudKit

/// The basic and CloudKit information making up a Multiqueue room.
struct Room {
    /// A unique ID for this song.
    var ID = UUID()
    /// Whether or not this view is active.
    var isActive: Bool
    /// Whether or not the hsot of this room is on-screen.
    var hostOnScreen: Bool
    /// The zone which corresponds to this room.
    var zone: CKRecordZone
    /// The customization details for this room.
    var details: RoomDetails
    /// The song currently playing by the host of this room.
    var nowPlayingSong: NowPlayingSong
    /// The share record corresponding to this room's zone.
    var share: CKShare
    /// The play type currently selected by the user.
    var selectedPlayType = PlayType.next
    /// The songs that have been added to this room's queue so far.
    var queueSongs: [QueueSong] = []
    /// This room's song limit.
    var songLimit: Int
    /// What should occur when this room's song limit expires.
    var songLimitAction: LimitExpirationAction
    /// This room's song limit, in seconds.
    var timeLimit: Int
    /// What should occur when this room's time limit expires.
    var timeLimitAction: LimitExpirationAction
}
