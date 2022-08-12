//
//  NowPlayingSong.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 7/30/22.
//

import Foundation
import MusicKit
import CloudKit

/// A song that is currently playing on the host's device.
struct NowPlayingSong {
    /// The CloudKit record corresponding to the song.
    var record: CKRecord
    /// The MusicKit `Song` object that is playing.
    var song: Song?
    /// The amount of time that the song has been playing, in seconds.
    var timeElapsed: Double
    /// The total song length, in seconds.
    var songTime: Double
    /// Artwork for this song.
    var artwork: CKAsset?
}
