//
//  CloudKitServices.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 7/31/22.
//

import Foundation
import CloudKit
import MusicKit
import UIKit

/// Uploads a song to the specified room zone to be inserted into the room's host's music queue.
/// - Parameters:
///   - song: The song to upload.
///   - zoneID: The ID of the zone to upload the room to.
///   - adderName: The name of the person who is uploading the song.
///   - playType: The type of queue insertion that this song should follow.
///   - database: The database to upload this song to.
///   - completionHandler: Code to run when the song upload operation has finished.
func uploadQueueSong(song: Song, zoneID: CKRecordZone.ID, adderName: String, playType: PlayType, database: CloudKitDatabase, completionHandler: @escaping (Result<CKRecord, Error>) -> Void) {
    let songRecord = CKRecord(recordType: "QueueSong", recordID: CKRecord.ID(recordName: "\(song.title) [\(adderName) Added \(playType == .next ? "For Next" : "For Later")] [\(Date().description)] [\(UUID())]", zoneID: zoneID))
    
    songRecord["Song"] = try! JSONEncoder().encode(song)
    songRecord["PlayType"] = playType == .next ? "Next" : "Later"
    songRecord["AdderName"] = adderName
    songRecord["TimeAdded"] = Date()
    songRecord["RecordName"] = songRecord.recordID.recordName
    songRecord["ZoneName"] = zoneID.zoneName
    songRecord["ZoneOwnerName"] = zoneID.ownerName
    
    let artworkURL = song.artwork?.url(width: 50, height: 50)
    let artworkFilename = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).png")
    if artworkURL != nil {
        try! UIImage(data: Data(contentsOf: artworkURL!), scale: UIScreen.main.scale)!.pngData()!.write(to: artworkFilename)
        songRecord["Artwork"] = CKAsset(fileURL: artworkFilename)
    }
    
    let songUploadOperation = CKModifyRecordsOperation(recordsToSave: [songRecord])
    
    songUploadOperation.perRecordSaveBlock = { (_ recordID: CKRecord.ID, _ saveResult: Result<CKRecord, Error>) -> Void in
        // Delete the artwork file to save space
        do {
            try FileManager.default.removeItem(at: artworkFilename)
        } catch {}
        
        completionHandler(saveResult)
    }
    
    if database == .privateDatabase {
        CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(songUploadOperation)
    } else if database == .sharedDatabase {
        CKContainer(identifier: "iCloud.Multiqueue").sharedCloudDatabase.add(songUploadOperation)
    }
}
