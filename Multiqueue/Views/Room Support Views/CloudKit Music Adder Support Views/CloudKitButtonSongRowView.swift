//
//  ButtonSongRowView.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/19/22.
//

import SwiftUI
import MusicKit
import CloudKit

/// A song row option view that can uplaod its song to the server.
struct CloudKitButtonSongRowView: View {
    
    // MARK: - View Variables
    /// The custom app delegate object for the app.
    @EnvironmentObject var appDelegate: MultiqueueAppDelegate
    /// The song this view represents.
    var song: Song
    /// The upload status for this view.
    @State var uploadStatus = OperationStatus.notStarted
    /// The artwork on this view.
    var artwork: Artwork?
    /// The room this view can upload to.
    @Binding var room: Room
    /// The database to use for uploads from this view.
    var database: CloudKitDatabase
    /// Whether or not this user is the host.
    var isHost: Bool
    
    // MARK: - View Body
    var body: some View {
        HStack {
            if song.title != "Not Pl" && artwork != nil {
                AsyncImage(url: URL(string: artwork!.url(width: 50, height: 50)!.absoluteString))
                    .frame(width: 50, height: 50)
                    .cornerRadius(5)
            } else {
                Image(systemName: "play.square")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            
            VStack(alignment: .leading) {
                Text(song.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                Text(song.artistName)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            switch uploadStatus {
            case .notStarted:
                Image(systemName: "plus.circle")
                    .foregroundColor(.accentColor)
                    .imageScale(.large)
            case .inProgress:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            case .success:
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
                    .imageScale(.large)
            case .failure:
                Image(systemName: "plus.circle")
                    .foregroundColor(.accentColor)
                    .imageScale(.large)
            }
        }
        .padding()
        .modifier(RectangleWrapper())
        .padding(.horizontal)
        .onTapGesture {
            if uploadStatus == .notStarted || uploadStatus == .failure {
                // Add the song to the local queue
                if isHost {
                    Task {
                        do {
                            try await SystemMusicPlayer.shared.queue.insert(song, position: room.selectedPlayType == .next ? .afterCurrentEntry : .tail)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                
                // Add the song to the server
                uploadStatus = .inProgress
                
                uploadQueueSong(song: song, zoneID: room.zone.zoneID, adderName: room.share.currentUserParticipant?.userIdentity.nameComponents?.formatted() ?? "the host", playType: room.selectedPlayType, database: database) { (_ saveResult: Result<CKRecord, Error>) -> Void in
                    switch saveResult {
                        
                    case .success(let record):
                        uploadStatus = .success
                        
                        let newQueueSong = QueueSong(song: try! JSONDecoder().decode(Song.self, from: record["Song"] as! Data), playType: record["PlayType"] as! String == "Next" ? .next : .later, adderName: record["AdderName"] as! String, timeAdded: record["TimeAdded"] as! Date, artwork: record["Artwork"] as! CKAsset)
                        
                        if let index = room.queueSongs.firstIndex(where: { $0.timeAdded < record["TimeAdded"] as! Date }) {
                            room.queueSongs.insert(newQueueSong, at: index)
                        } else {
                            room.queueSongs.append(newQueueSong)
                        }
                        
                    case .failure(let error):
                        uploadStatus = .failure
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

//struct CloudKitButtonSongRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        CloudKitButtonSongRowView(song: Song(), title: "Preview Title", subtitle: "Preview Artist", artwork: nil, showPlus: true)
//    }
//}
