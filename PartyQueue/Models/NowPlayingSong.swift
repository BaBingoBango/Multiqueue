//
//  NowPlayingSong.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 7/30/22.
//

import Foundation
import MusicKit
import CloudKit

struct NowPlayingSong {
    var record: CKRecord
    var song: Song?
    var timeElapsed: Double // in seconds
    var songTime: Double // in seconds
    var artwork: CKAsset?
}
