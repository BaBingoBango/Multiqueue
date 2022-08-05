//
//  QueueSong.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 7/31/22.
//

import Foundation
import MusicKit
import CloudKit

/// A song that was added to an Apple Music Queue via a Multiqueue room.
struct QueueSong {
    var ID = UUID()
    var song: Song
    var playType: PlayType
    var adderName: String
    var timeAdded: Date
    var artwork: CKAsset
}
