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
    /// A unique ID for this song.
    var ID = UUID()
    /// The MusicKit `Song` object.
    var song: Song
    /// The method by which this song should be inserted into a queue.
    var playType: PlayType
    /// The name of the person who added this song to the queue.
    var adderName: String
    /// The time this song was uploaded to CloudKit.
    var timeAdded: Date
    /// The artwork for this song.
    var artwork: CKAsset
}
