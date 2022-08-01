//
//  ButtonSongRowView.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/19/22.
//

import SwiftUI
import MusicKit
import CloudKit

struct CloudKitButtonSongRowView: View {
    /// The custom app delegate object for the app.
    @EnvironmentObject var appDelegate: MultiqueueAppDelegate
    
    var song: Song
    @State var uploadStatus = OperationStatus.notStarted
    var artwork: Artwork?
    @Binding var room: Room
    
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
                uploadStatus = .inProgress
                
                uploadQueueSong(song: song, zoneID: room.zone.zoneID, adderName: room.share.currentUserParticipant?.userIdentity.nameComponents?.formatted() ?? "the host", playType: room.selectedPlayType, database: .privateDatabase) { (_ saveResult: Result<CKRecord, Error>) -> Void in
                    switch saveResult {
                    case .success(_):
                        uploadStatus = .success
                        sleep(2)
                        appDelegate.notificationCompletionHandler = nil
                        appDelegate.notificationStatus = .responding
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
