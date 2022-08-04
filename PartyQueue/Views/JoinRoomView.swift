//
//  JoinRoomView.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 7/29/22.
//

import SwiftUI
import CloudKit
import MusicKit

struct JoinRoomView: View {
    
    // MARK: - View Variables
    @State var avaliableRooms: [Room] = []
    @State var roomUpdateStatus = OperationStatus.notStarted
    
    // MARK: - View Body
    var body: some View {
//        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.accentColor)
                            
                            Text("Can't Find Your Room?")
                                .foregroundColor(.accentColor)
                        }
                        .modifier(RectangleWrapper(fixedHeight: 50, color: .gray, opacity: 0.15))
                    }
                    .padding()
                    
                    switch roomUpdateStatus {
                    case .notStarted:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        
                    case .inProgress:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        
                    case .success:
                        if !avaliableRooms.isEmpty {
                            ForEach(0...avaliableRooms.count - 1, id: \.self) { eachIndex in
                                NavigationLink(destination: JoinedRoomView(room: avaliableRooms[eachIndex])) {
                                    RoomOptionView(roomDetails: avaliableRooms[eachIndex].details)
                                }
                                .padding(.horizontal)
                            }
                        } else {
                            Text("No Joinable Rooms Found")
                                .foregroundColor(.gray)
                                .fontWeight(.bold)
                                .font(.title3)
                                .padding(.top, 25)
                        }
                        
                    case .failure:
                        Text("Request Failure")
                        
                    }
                }
            }
            .onAppear {
                if roomUpdateStatus == .notStarted {
                    updateRoomList()
                }
            }
            
            // MARK: - Navigation View Settings
            .navigationTitle("Join Room")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if roomUpdateStatus != .inProgress {
                            updateRoomList()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            })
//        }
    }
    
    // MARK: - View Functions
    /// Connects to the server to update the list of rooms shared with the user.
    func updateRoomList() {
        avaliableRooms = []
        roomUpdateStatus = .inProgress
        
        var zonesToQuery: [CKRecordZone] = []
        let zoneFetchOperation = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
        
        zoneFetchOperation.perRecordZoneResultBlock = { (_ recordZoneID: CKRecordZone.ID, _ recordZoneResult: Result<CKRecordZone, Error>) -> Void in
            switch recordZoneResult {
            case .success(let zone):
                if zone.zoneID.zoneName.contains("] [") {
                    zonesToQuery.append(zone)
                }
                
            case .failure(let error):
                print(error.localizedDescription)
                roomUpdateStatus = .failure
            }
        }
        
        zoneFetchOperation.fetchRecordZonesResultBlock = { (_ operationResult: Result<Void, Error>) -> Void in
            switch operationResult {
            case .success():
                var queriedZones = 0
                
                if zonesToQuery.isEmpty {
                    roomUpdateStatus = .success
                }
                
                for eachZone in zonesToQuery {
                    let detailsQueryOperation = CKQueryOperation(query: CKQuery(recordType: "RoomDetails", predicate: NSPredicate(value: true)))
                    detailsQueryOperation.zoneID = eachZone.zoneID
                    
                    detailsQueryOperation.recordMatchedBlock = { (_ recordID: CKRecord.ID, _ recordResult: Result<CKRecord, Error>) -> Void in
                        switch recordResult {
                        case .success(let queriedRecord):
                            let roomDetails = RoomDetails(
                                name: queriedRecord["Name"] as! String,
                                icon: queriedRecord["Icon"] as! String,
                                color: Color(.sRGB, red: (queriedRecord["Color"] as! [Double])[0], green: (queriedRecord["Color"] as! [Double])[1], blue: (queriedRecord["Color"] as! [Double])[2], opacity: (queriedRecord["Color"] as! [Double])[3]),
                                description: queriedRecord["Description"] as! String
                            )
                            
                            let nowPlayingQueryOperation = CKQueryOperation(query: CKQuery(recordType: "NowPlayingSong", predicate: NSPredicate(value: true)))
                            nowPlayingQueryOperation.zoneID = eachZone.zoneID
                            
                            nowPlayingQueryOperation.recordMatchedBlock = { (_ recordID: CKRecord.ID, _ nowPlayingRecordResult: Result<CKRecord, Error>) -> Void in
                                switch nowPlayingRecordResult {
                                case .success(let nowPlayingRecord):
                                    let shareQueryOperation = CKQueryOperation(query: CKQuery(recordType: "cloudkit.share", predicate: NSPredicate(value: true)))
                                    shareQueryOperation.zoneID = eachZone.zoneID
                                    
                                    shareQueryOperation.recordMatchedBlock = { (_ recordID: CKRecord.ID, _ recordResult: Result<CKRecord, Error>) -> Void in
                                        switch recordResult {
                                        case .success(let result):
                                            avaliableRooms.append(Room(zone: eachZone, details: roomDetails, nowPlayingSong: NowPlayingSong(record: nowPlayingRecord, song: {
                                                do {
                                                    return try JSONDecoder().decode(Song.self, from: nowPlayingRecord["PlayingSong"] as! Data)
                                                } catch {
                                                    return nil
                                                }
                                            }(), timeElapsed: nowPlayingRecord["TimeElapsed"] as! Double, songTime: nowPlayingRecord["SongTime"] as! Double, artwork: nowPlayingRecord.allKeys().contains("AlbumArtwork") ? nowPlayingRecord["AlbumArtwork"] as? CKAsset : nil), share: result as! CKShare, songLimit: queriedRecord["SongLimit"] as! Int, timeLimit: queriedRecord["TimeLimit"] as! Int))
                                            
                                            queriedZones += 1
                                            if queriedZones == zonesToQuery.count {
                                                roomUpdateStatus = .success
                                            }
                                            
                                        case .failure(let error):
                                            print(error.localizedDescription)
                                            roomUpdateStatus = .failure
                                        }
                                    }
                                    
                                    CKContainer(identifier: "iCloud.Multiqueue").sharedCloudDatabase.add(shareQueryOperation)
                                    
                                case .failure(let error):
                                    print(error.localizedDescription)
                                    roomUpdateStatus = .failure
                                }
                            }
                            
                            CKContainer(identifier: "iCloud.Multiqueue").sharedCloudDatabase.add(nowPlayingQueryOperation)
                            
                        case .failure(let error):
                            print(error.localizedDescription)
                            roomUpdateStatus = .failure
                        }
                    }
                    
                    CKContainer(identifier: "iCloud.Multiqueue").sharedCloudDatabase.add(detailsQueryOperation)
                }
                
            case .failure(let error):
                print(error.localizedDescription)
                roomUpdateStatus = .failure
            }
        }
        
        CKContainer(identifier: "iCloud.Multiqueue").sharedCloudDatabase.add(zoneFetchOperation)
    }
}

struct JoinRoomView_Previews: PreviewProvider {
    static var previews: some View {
        JoinRoomView()
    }
}
