//
//  RoomView.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 7/29/22.
//

import SwiftUI
import CloudKit
import MusicKit
import simd

struct RoomView: View {
    
    // MARK: - View Variables
    /// The custom app delegate object for the app.
    @EnvironmentObject var appDelegate: MultiqueueAppDelegate
    
    @State var room: Room
    
    @State var isShowingMusicAdder = false
    @State var isShowingPeopleView = false
    @State var isShowingInfoView = false
    
    let nowPlayingUploadTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    let changeFetchTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    @State var queueChangeToken: CKServerChangeToken? = nil
    @State var hasCompletedInitialQueueUpdate = false
    @State var queueUpdateStatus = OperationStatus.inProgress
    
    // MARK: - View Body
    var body: some View {
        //NavigationView {
            VStack {
                ScrollView {
                    VStack {
                        HStack {
                            Text("Quick Info")
                                .font(.headline)
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
                        
//                        Image(systemName: "arrow.up")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 30)
//                            .padding(.top)
                        
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
                    CloudKitMusicAdder(room: $room, database: .privateDatabase)
                }
            }
            .padding(.bottom)
            .onReceive(nowPlayingUploadTimer) { time in
                // If the current system song has updated, update the Now Playing UI
                if (room.nowPlayingSong.song?.title != systemPlayingSongTitle) ||
                    (room.nowPlayingSong.song?.artistName != systemPlayingSongArtist) ||
                    (room.nowPlayingSong.song?.artwork != systemPlayingSongArtwork ||
                     (room.nowPlayingSong.timeElapsed, room.nowPlayingSong.song?.duration) != systemPlayingSongTime) {
                    
                    room.nowPlayingSong.song = systemPlayingSong
                    room.nowPlayingSong.timeElapsed = systemPlayingSongTime.0
                    room.nowPlayingSong.songTime = room.nowPlayingSong.song?.duration! ?? 0.0
                    
                    let artworkURL = systemPlayingSong?.artwork?.url(width: 50, height: 50)
                    let artworkFilename = FileManager.default.temporaryDirectory.appendingPathComponent("artwork-\(Date().description).png")
                    if artworkURL != nil {
                        try! UIImage(data: Data(contentsOf: artworkURL!), scale: UIScreen.main.scale)!.pngData()!.write(to: artworkFilename)
                        room.nowPlayingSong.artwork = CKAsset(fileURL: artworkFilename)
                    }
                    
                    // Update the Now Playing record on the server
                    room.nowPlayingSong.record["PlayingSong"] = try! JSONEncoder().encode(SystemMusicPlayer.shared.queue.currentEntry?.item)
                    room.nowPlayingSong.record["TimeElapsed"] = systemPlayingSongTime.0
                    room.nowPlayingSong.record["SongTime"] = systemPlayingSongTime.1
                    room.nowPlayingSong.record["AlbumArtwork"] = room.nowPlayingSong.artwork
                    
                    let nowPlayingUpdateOperation = CKModifyRecordsOperation(recordsToSave: [room.nowPlayingSong.record])
                    nowPlayingUpdateOperation.savePolicy = .allKeys
                    nowPlayingUpdateOperation.qualityOfService = .userInteractive
                    CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(nowPlayingUpdateOperation)
                }
            }
            .onAppear {
                if !hasCompletedInitialQueueUpdate {
                    getDataFromServer(afterDate: room.queueSongs.first?.timeAdded ?? Date.distantPast, zoneID: room.zone.zoneID, database: .privateDatabase)
                    hasCompletedInitialQueueUpdate = true
                }
            }
            .onReceive(changeFetchTimer) { time in
                // Update the list of queue songs to match the server's
                if queueUpdateStatus != .inProgress {
                    getDataFromServer(afterDate: room.queueSongs.first?.timeAdded ?? Date.distantPast, zoneID: room.zone.zoneID, database: .privateDatabase, fetchChanges: true)
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
                            CloudKitSharingView(room: room, container: CKContainer(identifier: "iCloud.Multiqueue"))
                        }
                        
                        Button(action: {
                            isShowingInfoView = true
                        }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.accentColor)
                        }
                        .sheet(isPresented: $isShowingInfoView) {
                            EmptyView()
                        }
                    }
                }
            })
        //}
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
            changeFetchOperation.qualityOfService = .userInteractive
            changeFetchOperation.recordWasChangedBlock = { (_ recordID: CKRecord.ID, _ recordResult: Result<CKRecord, Error>) -> Void in
                switch recordResult {
                    
                case .success(let record):
                    if record.recordType == "QueueSong" {
                        let newQueueSong = QueueSong(song: try! JSONDecoder().decode(Song.self, from: record["Song"] as! Data), playType: record["PlayType"] as! String == "Next" ? .next : .later, adderName: record["AdderName"] as! String, timeAdded: record["TimeAdded"] as! Date, artwork: record["Artwork"] as! CKAsset)
                        
                        // Add the song to the local queue
                        Task {
                            do {
                                try await SystemMusicPlayer.shared.queue.insert(newQueueSong.song, position: room.selectedPlayType == .next ? .afterCurrentEntry : .tail)
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                        
                        // Add the new song to the UI
                        if !room.queueSongs.contains(where: { newQueueSong.song == $0.song && newQueueSong.timeAdded == $0.timeAdded }) {
                            if let index = room.queueSongs.firstIndex(where: { $0.timeAdded < record["TimeAdded"] as! Date }) {
                                room.queueSongs.insert(newQueueSong, at: index)
                            } else {
                                room.queueSongs.append(newQueueSong)
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

//struct RoomView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoomView(room: Room(zone: CKRecordZone(zoneName: "Preview Zone"), details: RoomDetails(name: "Preview Room", icon: "🎶", color: .blue, description: "Preview description."), nowPlayingSong: NowPlayingSong(song: Song()), share: CKShare(recordZoneID: CKRecordZone.ID(zoneName: "Preview Zone", ownerName: "Preview Owner"))))
//    }
//}
