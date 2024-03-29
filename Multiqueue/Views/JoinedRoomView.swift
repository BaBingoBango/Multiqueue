//
//  JoinedRoomView.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 7/29/22.
//

import SwiftUI
import CloudKit
import MusicKit

/// A view surfacing controls for a room, in the context of a participant.
struct JoinedRoomView: View {
    
    // MARK: - View Variables
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
    
    /// A 0.5-second interval timer triggering Now Playing section updates on this view.
    let nowPlayingUpdateTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    /// The status of a currently running Now Playing update operation.
    @State var nowPlayingUpdateStatus = OperationStatus.notStarted
    
    /// The current CloudKit change token for this room's zone.
    @State var queueChangeToken: CKServerChangeToken? = nil
    /// A 3-second interval timer triggering queue updates on this view.
    let queueUpdateTimer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    /// Whether or not an initial queue update has completed on this view.
    @State var hasCompletedInitialQueueUpdate = false
    /// The status of a currently running queue update operation.
    @State var queueUpdateStatus = OperationStatus.notStarted
    /// A 0.5-second interval timer triggering view updates.
    let viewUpdateTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    /// Whether or not this view is being presented.
    @Binding var isRoomViewShowing: Bool
    
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
                        
                        if nowPlayingUpdateStatus == .inProgress {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding(.leading, 5)
                        } else if nowPlayingUpdateStatus == .failure {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .imageScale(.large)
                                .foregroundColor(.yellow)
                                .padding(.leading, 5)
                        }
                        
                        Spacer()
                    }
                    .padding([.top, .leading])
                    
                    if let song = room.nowPlayingSong.song {
                        SongRowView(title: song.title , subtitle: song.artistName, customArtwork: room.nowPlayingSong.artwork, mode: .withTimeBar, nowPlayingTime: (room.nowPlayingSong.timeElapsed, room.nowPlayingSong.songTime ))
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
                CloudKitMusicAdder(room: $room, isShowingLibraryPicker: $isShowingLibraryPicker, database: .sharedDatabase, isHost: false)
            }
            .disabled(!room.isActive || room.share.currentUserParticipant?.permission != .readWrite)
        }
        .padding(.bottom)
        .onAppear {
            if !hasCompletedInitialQueueUpdate {
                getDataFromServer(afterDate: room.queueSongs.first?.timeAdded ?? Date.distantPast, zoneID: room.zone.zoneID, database: .sharedDatabase)
                hasCompletedInitialQueueUpdate = true
            }
        }
        .onReceive(viewUpdateTimer) { time in
            // Update the list of queue songs to match the server's
            if queueUpdateStatus != .inProgress && !isShowingLibraryPicker {
                getDataFromServer(afterDate: room.queueSongs.first?.timeAdded ?? Date.distantPast, zoneID: room.zone.zoneID, database: .sharedDatabase, fetchChanges: true)
            }
        }
        .onChange(of: room.isActive) { newValue in
            if !newValue {
                isShowingMusicAdder = false
            }
        }
        .onChange(of: room.share.currentUserParticipant?.permission) { newValue in
            if newValue != .readWrite {
                isShowingMusicAdder = false
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
                        CloudKitSharingView(room: room, container: CKContainer(identifier: "iCloud.Multiqueue"), deletedShare: .constant(false))
                    }
                    
                    Button(action: {
                        isShowingInfoView = true
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.accentColor)
                    }
                    .sheet(isPresented: $isShowingInfoView) {
                        RoomInfoView(room: $room, isHost: false, isRoomViewShowing: $isRoomViewShowing)
                    }
                }
            }
        })
    }
    
    // MARK: - View Functions
    /// Updates the view with data from the server.
    /// - Parameters:
    ///   - afterDate: The date for which all downloaded queue songs should be added after.
    ///   - zoneID: The ID of this room's zone.
    ///   - database: The database to use to access this room's zone.
    ///   - fetchChanges: Whether or not to fetch only record changes, or to fetch all `QueueSong` records.
    ///   - promptedByNotification: Whether or not this function is being called as part of a notification response.
    func getDataFromServer(afterDate: Date, zoneID: CKRecordZone.ID, database: CloudKitDatabase, fetchChanges: Bool = false, promptedByNotification: Bool = false) {
        queueUpdateStatus = .inProgress
        nowPlayingUpdateStatus = .inProgress
        
        if !fetchChanges {
            // Fetch the initial Now Playing song from the server
            nowPlayingUpdateStatus = .inProgress
            
            let nowPlayingQueryOperation = CKQueryOperation(query: CKQuery(recordType: "NowPlayingSong", predicate: NSPredicate(value: true)))
            nowPlayingQueryOperation.zoneID = room.zone.zoneID
            
            nowPlayingQueryOperation.recordMatchedBlock = { (_ recordID: CKRecord.ID, _ nowPlayingRecordResult: Result<CKRecord, Error>) -> Void in
                switch nowPlayingRecordResult {
                case .success(let nowPlayingRecord):
                    room.nowPlayingSong = NowPlayingSong(record: nowPlayingRecord, song: {
                        do {
                            return try JSONDecoder().decode(Song.self, from: nowPlayingRecord["PlayingSong"] as! Data)
                        } catch {
                            return nil
                        }
                    }(), timeElapsed: nowPlayingRecord["TimeElapsed"] as! Double, songTime: nowPlayingRecord["SongTime"] as! Double, artwork: nowPlayingRecord["AlbumArtwork"] as? CKAsset)
                    nowPlayingUpdateStatus = .success
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    nowPlayingUpdateStatus = .failure
                }
            }
            
            CKContainer(identifier: "iCloud.Multiqueue").sharedCloudDatabase.add(nowPlayingQueryOperation)
            
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
                        // Add a new queue song to the UI
                        let newQueueSong = QueueSong(song: try! JSONDecoder().decode(Song.self, from: record["Song"] as! Data), playType: record["PlayType"] as! String == "Next" ? .next : .later, adderName: record["AdderName"] as! String, timeAdded: record["TimeAdded"] as! Date, artwork: record["Artwork"] as! CKAsset)
                        
                        if !room.queueSongs.contains(where: { newQueueSong.song == $0.song && newQueueSong.timeAdded == $0.timeAdded }) {
                            if let index = room.queueSongs.firstIndex(where: { $0.timeAdded < record["TimeAdded"] as! Date }) {
                                room.queueSongs.insert(newQueueSong, at: index)
                            } else {
                                room.queueSongs.append(newQueueSong)
                            }
                        }
                        
                    } else if record.recordType == "NowPlayingSong" {
                        // Update the Now Playing song in the UI
                        room.nowPlayingSong = NowPlayingSong(record: record, song: {
                            do {
                                return try JSONDecoder().decode(Song.self, from: record["PlayingSong"] as! Data)
                            } catch {
                                return nil
                            }
                        }(), timeElapsed: record["TimeElapsed"] as! Double, songTime: record["SongTime"] as! Double, artwork: record["AlbumArtwork"] as? CKAsset)
                        nowPlayingUpdateStatus = .success
                        
                    } else if record.recordType == "cloudkit.share" {
                        // Update the room's local share record
                        room.share = record as! CKShare
                        
                    } else if record.recordType == "RoomDetails" {
                        // Update the room's local copy of the details
                        room.details = RoomDetails(
                            name: record["Name"] as! String,
                            icon: record["Icon"] as! String,
                            color: Color(.sRGB, red: (record["Color"] as! [Double])[0], green: (record["Color"] as! [Double])[1], blue: (record["Color"] as! [Double])[2], opacity: (record["Color"] as! [Double])[3]),
                            description: record["Description"] as! String,
                            record: record
                        )
                        
                        // Keep a record of previous limits
                        let previousSongsLeft = room.songLimit
                        let previousTimeLeft = room.timeLimit
                        
                        // Update other room variables
                        room.isActive = record["IsActive"] as! Int == 1 ? true : false
                        room.hostOnScreen = record["HostOnScreen"] as! Int == 1 ? true : false
                        room.songLimit = record["SongLimit"] as! Int
                        room.songLimitAction = convertStringToLimitExpirationAction(record["SongLimitAction"] as! String)
                        room.timeLimit = record["TimeLimit"] as! Int
                        room.timeLimitAction = convertStringToLimitExpirationAction(record["TimeLimitAction"] as! String)
                        
                        // Perform limit actions if needed
                        if room.songLimit <= 0 && previousSongsLeft > 0 {
                            if room.songLimitAction == .deleteRoom {
                                isRoomViewShowing = false
                            }
                        }
                        if room.timeLimit <= 0 && previousTimeLeft > 0 {
                            if room.timeLimitAction == .deleteRoom {
                                isRoomViewShowing = false
                            }
                        }
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
                        getDataFromServer(afterDate: room.queueSongs.first?.timeAdded ?? Date.distantPast, zoneID: room.zone.zoneID, database: .sharedDatabase)
                    } else {
                        queueUpdateStatus = .success
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    queueUpdateStatus = .failure
                }
            }
            
//            changeFetchOperation.qualityOfService = .userInteractive
            if database == .privateDatabase {
                CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(changeFetchOperation)
            } else if database == .sharedDatabase {
                CKContainer(identifier: "iCloud.Multiqueue").sharedCloudDatabase.add(changeFetchOperation)
            }
        }
    }
}
