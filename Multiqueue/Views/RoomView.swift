//
//  RoomView.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 7/29/22.
//

import SwiftUI
import CloudKit
import MusicKit

/// A view surfacing controls for a room, in the context of a host.
struct RoomView: View {
    
    // MARK: - View Variables
    /// The custom app delegate object for the app.
    @EnvironmentObject var appDelegate: MultiqueueAppDelegate
    
    /// The room this view surfaces controls for.
    @State var room: Room
    
    /// Whether or not the music adder view is being presented.
    @State var isShowingMusicAdder = false
    /// Whether or not the library adder view is being presented.
    @State var isShowingLibraryPicker = false
    /// Whether or not the People view is being presented.
    @State var isShowingPeopleView = false
    /// Whether or not the room information view is being presented.
    @State var isShowingInfoView = false
    
    /// A 0.5-second interval timer triggering data upload on this view.
    let dataUploadTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    /// A 0.5-second interval timer triggering change fetching on this view.
    let changeFetchTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    /// A 1-second interval timer triggering time limit updates on this view.
    let timeLimitTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    /// The current CloudKit change token for this room's zone.
    @State var queueChangeToken: CKServerChangeToken? = nil
    /// Whether or not an initial queue update has completed on this view.
    @State var hasCompletedInitialQueueUpdate = false
    /// The status of a currently running queue update operation.
    @State var queueUpdateStatus = OperationStatus.inProgress
    
    /// Whether or not this view is being presented.
    @Binding var isRoomViewShowing: Bool
    
    /// Whether or not this room's share was deleted.
    @State var deletedShare = false
    
    // MARK: - View Body
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    HStack {
                        Text("\(room.share.participants.count) Participant\(room.share.participants.count != 1 ? "s" : "")")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.leading)
                    
                    HStack {
                        if room.songLimit <= 0 {
                            Text("No Song Limit")
                                .font(.headline)
                        } else {
                            Text("\(room.songLimit) Song\(room.songLimit != 1 ? "s" : "") Remaining")
                                .font(.headline)
                        }
                        Spacer()
                    }
                    .padding(.leading)
                    
                    HStack {
                        if room.timeLimit <= 0 {
                            Text("No Time Limit")
                                .font(.headline)
                        } else {
                            Text(verbatim: {
                                let timeLeft = secondsToHoursMinutesSeconds(room.timeLimit)
                                return "\(timeLeft.0 < 10 ? "0" : "")\(timeLeft.0):\(timeLeft.1 < 10 ? "0" : "")\(timeLeft.1):\(timeLeft.2 < 10 ? "0" : "")\(timeLeft.2) Remaining"
                            }())
                                .font(.headline)
                        }
                        Spacer()
                    }
                    .padding(.leading)
                    
                    HStack {
                        Text("Now Playing")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding([.top, .leading])
                    
                    if let song = room.nowPlayingSong.song {
                        SongRowView(title: song.title , subtitle: song.artistName, customArtwork: room.nowPlayingSong.artwork, mode: .withSongControls, nowPlayingTime: (room.nowPlayingSong.timeElapsed, room.nowPlayingSong.songTime ))
                    } else {
                        SongRowView(title: "Not Playing" , subtitle: "", mode: .songOnly, nowPlayingTime: (room.nowPlayingSong.timeElapsed, room.nowPlayingSong.songTime ))
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Added to Queue")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        if queueUpdateStatus == .inProgress {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding(.leading, 5)
                        } else if queueUpdateStatus == .failure {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .imageScale(.large)
                                .foregroundColor(.yellow)
                                .padding(.leading, 5)
                        }
                        
                        Spacer()
                    }
                    .padding([.top, .leading])
                    
                    ForEach(room.queueSongs, id: \.ID) { song in
                        SongRowView(title: song.song.title, subtitle: song.song.artistName, artwork: song.song.artwork, subsubtitle: "Added by \(song.adderName) for \(song.playType == .next ? "next" : "later") at \(song.timeAdded.formatted(date: .omitted, time: .standard))")
                    }
                    
                }
            }
            
            Button(action: {
                isShowingMusicAdder.toggle()
            }) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.accentColor)
                        .cornerRadius(15)
                        .frame(height: 55)
                    Text("Add Songs to Queue")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .padding([.top, .leading, .trailing])
            .sheet(isPresented: $isShowingMusicAdder) {
                CloudKitMusicAdder(room: $room, isShowingLibraryPicker: $isShowingLibraryPicker, database: .privateDatabase, isHost: true)
            }
        }
        .padding(.bottom)
        .onReceive(dataUploadTimer) { time in
            var shouldUploadNowPlaying = false
            
            // If the current system song has updated, update the Now Playing UI
            if (room.nowPlayingSong.song?.title != systemPlayingSongTitle) ||
                (room.nowPlayingSong.song?.artistName != systemPlayingSongArtist) ||
                (room.nowPlayingSong.song?.artwork != systemPlayingSongArtwork ||
                 (room.nowPlayingSong.timeElapsed, room.nowPlayingSong.song?.duration) != systemPlayingSongTime) {
                shouldUploadNowPlaying = true
                
                room.nowPlayingSong.song = systemPlayingSong
                room.nowPlayingSong.timeElapsed = systemPlayingSongTime.0
                room.nowPlayingSong.songTime = room.nowPlayingSong.song?.duration! ?? 0.0
                
                let artworkURL = systemPlayingSong?.artwork?.url(width: 50, height: 50)
                let artworkFilename = FileManager.default.temporaryDirectory.appendingPathComponent("artwork-\(Date().description).png")
                if artworkURL != nil {
                    try! UIImage(data: Data(contentsOf: artworkURL!), scale: UIScreen.main.scale)!.pngData()!.write(to: artworkFilename)
                    room.nowPlayingSong.artwork = CKAsset(fileURL: artworkFilename)
                }
                
                // Prepare a new copy of the Now Playing record
                room.nowPlayingSong.record["PlayingSong"] = try! JSONEncoder().encode(SystemMusicPlayer.shared.queue.currentEntry?.item)
                room.nowPlayingSong.record["TimeElapsed"] = systemPlayingSongTime.0
                room.nowPlayingSong.record["SongTime"] = systemPlayingSongTime.1
                room.nowPlayingSong.record["AlbumArtwork"] = room.nowPlayingSong.artwork
            }
            
            // Prepare a new copy of the room details
            room.details.record["IsActive"] = room.isActive ? 1 : 0
            room.details.record["HostOnScreen"] = 1
            room.details.record["Color"] = [
                Double(room.details.color.cgColor?.components![0] ?? 1),
                Double(room.details.color.cgColor?.components![1] ?? 0),
                Double(room.details.color.cgColor?.components![2] ?? 0),
                Double(room.details.color.cgColor?.components![3] ?? 1)
            ]
            room.details.record["Description"] = room.details.description
            room.details.record["Icon"] = room.details.icon
            room.details.record["Name"] = room.details.name
            room.details.record["SongLimit"] = room.songLimit
            room.details.record["SongLimitAction"] = convertLimitExpirationActionToString(room.songLimitAction)
            room.details.record["TimeLimit"] = room.timeLimit
            room.details.record["TimeLimitAction"] = convertLimitExpirationActionToString(room.timeLimitAction)
            
            // Compile the records to upload
            var records: [CKRecord] = [room.details.record]
            if shouldUploadNowPlaying {
                records.append(room.nowPlayingSong.record)
            }
            
            // Upload the records to the server
            let nowPlayingUpdateOperation = CKModifyRecordsOperation(recordsToSave: records)
            nowPlayingUpdateOperation.savePolicy = .allKeys
            nowPlayingUpdateOperation.qualityOfService = .userInteractive
            CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(nowPlayingUpdateOperation)
            
            // After the initial upload, check if a share record still exists
            var locatedShare = false
            let shareQueryOperation = CKQueryOperation(query: CKQuery(recordType: "cloudkit.share", predicate: NSPredicate(value: true)))
            shareQueryOperation.zoneID = room.zone.zoneID
            
            shareQueryOperation.recordMatchedBlock = { (_ recordID: CKRecord.ID, _ recordResult: Result<CKRecord, Error>) -> Void in
                switch recordResult {
                case .success(_):
                    locatedShare = true
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            shareQueryOperation.queryResultBlock = { (_ operationResult: Result<CKQueryOperation.Cursor?, Error>) -> Void in
                if !locatedShare {
                    // If the share is gone, upload a new one
                    room.share = CKShare(recordZoneID: room.zone.zoneID)
                    room.share[CKShare.SystemFieldKey.title] = room.details.name as CKRecordValue
                    room.share[CKShare.SystemFieldKey.shareType] = "Room" as CKRecordValue
                    room.share[CKShare.SystemFieldKey.thumbnailImageData] = NSDataAsset(name: "Rounded App Icon")!.data as CKRecordValue
                    room.share.publicPermission = .readWrite
                    
                    let shareUploadOperation = CKModifyRecordsOperation(recordsToSave: [room.share])
                    CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(shareUploadOperation)
                }
            }
            
            CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(shareQueryOperation)
        }
        .onAppear {
            if !hasCompletedInitialQueueUpdate {
                getDataFromServer(afterDate: room.queueSongs.first?.timeAdded ?? Date.distantPast, zoneID: room.zone.zoneID, database: .privateDatabase)
                hasCompletedInitialQueueUpdate = true
            }
        }
        .onReceive(changeFetchTimer) { time in
            // Update the list of queue songs to match the server's
            if queueUpdateStatus != .inProgress && !isShowingInfoView && !isShowingLibraryPicker {
                getDataFromServer(afterDate: room.queueSongs.first?.timeAdded ?? Date.distantPast, zoneID: room.zone.zoneID, database: .privateDatabase, fetchChanges: true)
            }
        }
        .onReceive(timeLimitTimer) { time in
            if !isShowingInfoView && !isShowingLibraryPicker {
                if room.timeLimit > 0 {
                    room.timeLimit -= 1
                    
                    // If the song limit expires, perform the requested action
                    if room.timeLimit <= 0 {
                        switch room.timeLimitAction {
                        case .nothing:
                            print("Nothing is happening!")
                            
                        case .deactivateRoom:
                            room.isActive = false
                            
                        case .removeParticipants:
                            for eachParticipant in room.share.participants {
                                if eachParticipant != room.share.owner {
                                    room.share.removeParticipant(eachParticipant)
                                }
                            }
                            
                        case .deleteRoom:
                            let roomDeleteOperation = CKModifyRecordZonesOperation(recordZoneIDsToDelete: [room.zone.zoneID])
                            
                            roomDeleteOperation.perRecordZoneDeleteBlock = { (_ recordZoneID: CKRecordZone.ID, _ deleteResult: Result<Void, Error>) -> Void in
                                switch deleteResult {
                                case .success():
                                    isRoomViewShowing = false
                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                            }
                            
                            CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(roomDeleteOperation)
                        }
                    }
                }
            }
        }
        
        // MARK: - Navigation View Settings
        .navigationTitle(room.details.name)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 25) {
                    Button(action: {
                        isShowingPeopleView = true
                    }) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .foregroundColor(.accentColor)
                    }
                    .sheet(isPresented: $isShowingPeopleView) {
                        CloudKitSharingView(room: room, container: CKContainer(identifier: "iCloud.Multiqueue"), deletedShare: $deletedShare)
                    }
                    
                    Button(action: {
                        isShowingInfoView = true
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.accentColor)
                    }
                    .sheet(isPresented: $isShowingInfoView) {
                        RoomInfoView(room: $room, isHost: true, isRoomViewShowing: $isRoomViewShowing)
                    }
                }
            }
        })
    }
    
    // MARK: - View Functions
    // Updates the view with data from the server.
    /// - Parameters:
    ///   - afterDate: The date for which all downloaded queue songs should be added after.
    ///   - zoneID: The ID of this room's zone.
    ///   - database: The database to use to access this room's zone.
    ///   - fetchChanges: Whether or not to fetch only record changes, or to fetch all `QueueSong` records.
    ///   - promptedByNotification: Whether or not this function is being called as part of a notification response.
    func getDataFromServer(afterDate: Date, zoneID: CKRecordZone.ID, database: CloudKitDatabase, fetchChanges: Bool = false, promptedByNotification: Bool = false) {
        queueUpdateStatus = .inProgress
        
        if !fetchChanges {
            // Fetch initial queue songs from the sever
            queueUpdateStatus = .inProgress
            
            let songQuery = CKQuery(recordType: "QueueSong", predicate: NSPredicate(format: "TimeAdded > %@", afterDate as CVarArg))
            songQuery.sortDescriptors = [NSSortDescriptor(key: "TimeAdded", ascending: false)]
            let songQueryOperation = CKQueryOperation(query: songQuery)
            songQueryOperation.zoneID = zoneID
            
            var newSongs: [QueueSong] = []
            
            songQueryOperation.recordMatchedBlock = { (_ recordID: CKRecord.ID, _ recordResult: Result<CKRecord, Error>) -> Void in
                switch recordResult {
                    
                case .success(let record):
                    let newSong = QueueSong(song: try! JSONDecoder().decode(Song.self, from: record["Song"] as! Data),
                                            playType: {
                        let playTypeString = record["PlayType"] as! String
                        if playTypeString == "Next" {
                            return .next
                        } else {
                            return .later
                        }
                    }(),
                                            adderName: record["AdderName"] as! String,
                                            timeAdded: record["TimeAdded"] as! Date,
                                            artwork: record["Artwork"] as! CKAsset)
                    newSongs.append(newSong)
                case .failure(let error):
                    print(error.localizedDescription)
                    queueUpdateStatus = .failure
                }
            }
            
            songQueryOperation.queryResultBlock = { (_ operationResult: Result<CKQueryOperation.Cursor?, Error>) -> Void in
                switch operationResult {
                    
                case .success(_):
                    if !newSongs.isEmpty {
                        room.queueSongs = newSongs + room.queueSongs
                        queueUpdateStatus = .success
                    } else {
                        queueUpdateStatus = .success
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    queueUpdateStatus = .failure
                }
            }
            
            if database == .privateDatabase {
                CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(songQueryOperation)
            } else if database == .sharedDatabase {
                CKContainer(identifier: "iCloud.Multiqueue").sharedCloudDatabase.add(songQueryOperation)
            }
            
        } else {
            
            // Fetch changes for the Now Playing song, queue songs, and the share record
            let changeFetchConfiguration = CKFetchRecordZoneChangesOperation.ZoneConfiguration(previousServerChangeToken: queueChangeToken)
            let changeFetchOperation = CKFetchRecordZoneChangesOperation(recordZoneIDs: [zoneID], configurationsByRecordZoneID: [zoneID : changeFetchConfiguration])
            changeFetchOperation.recordWasChangedBlock = { (_ recordID: CKRecord.ID, _ recordResult: Result<CKRecord, Error>) -> Void in
                switch recordResult {
                    
                case .success(let record):
                    if record.recordType == "QueueSong" {
                        let newQueueSong = QueueSong(song: try! JSONDecoder().decode(Song.self, from: record["Song"] as! Data), playType: record["PlayType"] as! String == "Next" ? .next : .later, adderName: record["AdderName"] as! String, timeAdded: record["TimeAdded"] as! Date, artwork: record["Artwork"] as! CKAsset)
                        
                        // Add the new song to the UI
                        if !room.queueSongs.contains(where: { newQueueSong.song == $0.song && newQueueSong.timeAdded == $0.timeAdded }) {
                            if let index = room.queueSongs.firstIndex(where: { $0.timeAdded < record["TimeAdded"] as! Date }) {
                                room.queueSongs.insert(newQueueSong, at: index)
                            } else {
                                room.queueSongs.append(newQueueSong)
                            }
                        }
                        
                        // Decrement the song limit
                        if room.songLimit > 0 {
                            room.songLimit -= 1
                            
                            // If the song limit expires, perform the requested action
                            if room.songLimit <= 0 {
                                switch room.songLimitAction {
                                case .nothing:
                                    print("Nothing is happening!")
                                    
                                case .deactivateRoom:
                                    room.isActive = false
                                    
                                case .removeParticipants:
                                    for eachParticipant in room.share.participants {
                                        if eachParticipant != room.share.owner {
                                            room.share.removeParticipant(eachParticipant)
                                        }
                                    }
                                    
                                case .deleteRoom:
                                    let roomDeleteOperation = CKModifyRecordZonesOperation(recordZoneIDsToDelete: [room.zone.zoneID])
                                    
                                    roomDeleteOperation.perRecordZoneDeleteBlock = { (_ recordZoneID: CKRecordZone.ID, _ deleteResult: Result<Void, Error>) -> Void in
                                        switch deleteResult {
                                        case .success():
                                            isRoomViewShowing = false
                                        case .failure(let error):
                                            print(error.localizedDescription)
                                        }
                                    }
                                    
                                    CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(roomDeleteOperation)
                                }
                            }
                        }
                        
                    } else if record.recordType == "cloudkit.share" {
                        // Update the room's local share record
                        room.share = record as! CKShare
                        
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    queueUpdateStatus = .failure
                }
            }
            
            changeFetchOperation.recordZoneChangeTokensUpdatedBlock = { (_ zoneID: CKRecordZone.ID, _ token: CKServerChangeToken?, _ data: Data?) -> Void in
                if token != nil {
                    queueChangeToken = token
                }
            }
            
            changeFetchOperation.recordZoneFetchResultBlock = { (_ recordZoneID: CKRecordZone.ID, _ fetchChangesResult: Result<(serverChangeToken: CKServerChangeToken, clientChangeTokenData: Data?, moreComing: Bool), Error>) -> Void in
                switch fetchChangesResult {
                    
                case .success((let serverChangeToken, _, let moreComing)):
                    queueChangeToken = serverChangeToken
                    if moreComing {
                        getDataFromServer(afterDate: room.queueSongs.first?.timeAdded ?? Date.distantPast, zoneID: room.zone.zoneID, database: .privateDatabase)
                    } else {
                        queueUpdateStatus = .success
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    queueUpdateStatus = .failure
                }
            }
            
            if database == .privateDatabase {
                CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(changeFetchOperation)
            } else if database == .sharedDatabase {
                CKContainer(identifier: "iCloud.Multiqueue").sharedCloudDatabase.add(changeFetchOperation)
            }
        }
    }
}
