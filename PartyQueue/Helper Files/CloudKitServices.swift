//
//  CloudKitServices.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 7/31/22.
//

import Foundation
import CloudKit
import MusicKit

/// Uploads a song to the specified room zone to be inserted into the room's host's music queue.
func uploadQueueSong(song: Song, zoneID: CKRecordZone.ID, adderName: String, playType: PlayType) {
    let songRecord = CKRecord(recordType: "QueueSong", recordID: CKRecord.ID(recordName: "\(song.title) [\(adderName) \(playType == .next ? "for next" : "for later")] [\(Date().description)] [\(UUID())]", zoneID: zoneID))
}
