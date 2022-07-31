//
//  JoinedRoomView.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 7/29/22.
//

import SwiftUI
import CloudKit
import MusicKit

struct JoinedRoomView: View {
    
    // MARK: - View Variables
    @State var room: Room
    
    @State var isShowingMusicAdder = false
    @State var isShowingPeopleView = false
    @State var isShowingInfoView = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - View Body
    var body: some View {
//        NavigationView {
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
                        
                        SongRowView(title: room.nowPlayingSong.song.title , subtitle: room.nowPlayingSong.song.artistName, customArtwork: room.nowPlayingSong.artwork, mode: .withTimeBar, nowPlayingTime: (room.nowPlayingSong.timeElapsed , room.nowPlayingSong.songTime ))
                        
                        Image(systemName: "arrow.up")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30)
                            .padding(.top)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Added to Queue")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                        }
                        .padding([.top, .leading])
                        
                        ForEach(1...5, id: \.self) { entry in
                            SongRowView(title: "Cool Song", subtitle: "Cool Band", artwork: nil, subsubtitle: "Added by someone at some time")
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
                    MusicAdder()
                }
            }
            .padding(.bottom)
            .onReceive(timer) { time in
                // Update the UI Now Playing song to match the server's
                let nowPlayingQueryOperation = CKQueryOperation(query: CKQuery(recordType: "NowPlayingSong", predicate: NSPredicate(value: true)))
                nowPlayingQueryOperation.zoneID = room.zone.zoneID
                
                nowPlayingQueryOperation.recordMatchedBlock = { (_ recordID: CKRecord.ID, _ nowPlayingRecordResult: Result<CKRecord, Error>) -> Void in
                    switch nowPlayingRecordResult {
                    case .success(let nowPlayingRecord):
                        room.nowPlayingSong = NowPlayingSong(record: nowPlayingRecord, song: try! JSONDecoder().decode(Song.self, from: nowPlayingRecord["Song"] as! Data), timeElapsed: nowPlayingRecord["TimeElapsed"] as! Double, songTime: nowPlayingRecord["SongTime"] as! Double, artwork: nowPlayingRecord["Artwork"] as! CKAsset)
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                
                CKContainer(identifier: "iCloud.Multiqueue").sharedCloudDatabase.add(nowPlayingQueryOperation)
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
//        }
    }
}

//struct JoinedRoomView_Previews: PreviewProvider {
//    static var previews: some View {
//        JoinedRoomView(room: (CKRecordZone(zoneName: "Preview Zone"), RoomDetails(name: "Preview Room", icon: "🎶", color: .blue, description: "Preview description."), CKShare(recordZoneID: CKRecordZone.ID(zoneName: "Preview Zone", ownerName: "Preview Owner"))))
//    }
//}
