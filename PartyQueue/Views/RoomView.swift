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
    @State var room: Room
    
    @State var isShowingMusicAdder = false
    @State var isShowingPeopleView = false
    @State var isShowingInfoView = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
                        
                        SongRowView(title: room.nowPlayingSong.song.title , subtitle: room.nowPlayingSong.song.artistName , artwork: room.nowPlayingSong.song.artwork, mode: .withSongControls, nowPlayingTime: (room.nowPlayingSong.timeElapsed , room.nowPlayingSong.songTime ))
                        
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
                    CloudKitMusicAdder()
                }
            }
            .padding(.bottom)
            .onReceive(timer) { time in
                // If the current system song has updated, update the Now Playing UI
                if (room.nowPlayingSong.song.title != systemPlayingSongTitle) ||
                    (room.nowPlayingSong.song.artistName != systemPlayingSongArtist) ||
                    (room.nowPlayingSong.song.artwork != systemPlayingSongArtwork ||
                     (room.nowPlayingSong.timeElapsed, room.nowPlayingSong.song.duration) != systemPlayingSongTime) {
                    
                    room.nowPlayingSong.song = systemPlayingSong!
                    room.nowPlayingSong.timeElapsed = systemPlayingSongTime.0
                    room.nowPlayingSong.songTime = room.nowPlayingSong.song.duration!
                    
                    let artworkURL = systemPlayingSong?.artwork?.url(width: 50, height: 50)
                    let artworkFilename = FileManager.default.temporaryDirectory.appendingPathComponent("artwork-\(Date().description).png")
                    if artworkURL != nil {
                        try! UIImage(data: Data(contentsOf: artworkURL!), scale: UIScreen.main.scale)!.pngData()!.write(to: artworkFilename)
                        room.nowPlayingSong.artwork = CKAsset(fileURL: artworkFilename)
                    }
                    
                    // Update the Now Playing record on the server
                    room.nowPlayingSong.record["Song"] = try! JSONEncoder().encode(SystemMusicPlayer.shared.queue.currentEntry?.item)
                    room.nowPlayingSong.record["TimeElapsed"] = systemPlayingSongTime.0
                    room.nowPlayingSong.record["SongTime"] = systemPlayingSongTime.1
                    room.nowPlayingSong.record["Artwork"] = room.nowPlayingSong.artwork
                    
                    let nowPlayingUpdateOperation = CKModifyRecordsOperation(recordsToSave: [room.nowPlayingSong.record])
                    nowPlayingUpdateOperation.savePolicy = .allKeys
                    nowPlayingUpdateOperation.qualityOfService = .userInteractive
                    CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(nowPlayingUpdateOperation)
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
}

//struct RoomView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoomView(room: Room(zone: CKRecordZone(zoneName: "Preview Zone"), details: RoomDetails(name: "Preview Room", icon: "🎶", color: .blue, description: "Preview description."), nowPlayingSong: NowPlayingSong(song: Song()), share: CKShare(recordZoneID: CKRecordZone.ID(zoneName: "Preview Zone", ownerName: "Preview Owner"))))
//    }
//}
