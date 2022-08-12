//
//  LibraryAdder.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/18/22.
//

import SwiftUI
import MediaPlayer
import MusicKit
import CloudKit

/// The view for adding music via the user's Apple Music library.
struct CloudKitLibraryAdder: View {
    
    // MARK: - View Variables
    /// The custom app delegate object for the app.
    @EnvironmentObject var appDelegate: MultiqueueAppDelegate
    /// Whether or not this view is being presented.
    @Binding var isShowingLibraryPicker: Bool
    /// The `PresentationMode` variable for this view.
    @Environment(\.presentationMode) var presentationMode
    /// The room this view can add songs to.
    @Binding var room: Room
    /// Whether or not the current user is the host.
    var isHost: Bool
    /// The database to use for CloudKit operations from this view.
    var database: CloudKitDatabase
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            VStack {
                
                Picker("Choose a Play Type", selection: $room.selectedPlayType) {
                    ForEach([PlayType.next, PlayType.later], id: \.self) { playType in
                        if playType == .next {
                            Text("Play Songs Next")
                        } else {
                            Text("Play Songs Later")
                        }
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                HStack {
                    Image(systemName: "music.note.house.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.secondary)
                        .hidden()
                    Image(systemName: "music.note.house.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.secondary)
                    Image(systemName: "music.note.house.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.secondary)
                        .hidden()
                }
                .padding([.top, .leading, .trailing])
                
                Button(action: {
                    isShowingLibraryPicker.toggle()
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.accentColor)
                            .cornerRadius(15)
                            .frame(height: 55)
                        Text("Open Apple Music Library")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .padding([.top, .leading, .trailing])
                .sheet(isPresented: $isShowingLibraryPicker) {
                    CloudKitSwiftUIMPMediaPickerController(room: $room, database: database, isHost: isHost)
                }
                
                Spacer()
                
            }
            
            // MARK: - Navigation Bar Settings
            .navigationBarItems(trailing: Button(action: { self.presentationMode.wrappedValue.dismiss() }) { Text("Done").fontWeight(.bold) })
            .navigationBarTitle("Add from Library", displayMode: .inline)
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CloudKitSwiftUIMPMediaPickerController: UIViewControllerRepresentable {
    
    @Binding var room: Room
    /// The custom app delegate object for the app.
    @EnvironmentObject var appDelegate: MultiqueueAppDelegate
    var database: CloudKitDatabase
    var isHost: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, room)
    }
    
    func makeUIViewController(context: Context) -> MPMediaPickerController {
        // MARK: Library Picker Settings
        let mediaPickerController = MPMediaPickerController(mediaTypes: .music)
        mediaPickerController.delegate = context.coordinator
        mediaPickerController.allowsPickingMultipleItems = true
        mediaPickerController.prompt = "Select songs to send to the queue:"
        
        return mediaPickerController
    }
    
    func updateUIViewController(_ uiViewController: MPMediaPickerController, context: Context) {}
    
    class Coordinator: NSObject, MPMediaPickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CloudKitSwiftUIMPMediaPickerController
        init(_ mediaPickerController: CloudKitSwiftUIMPMediaPickerController, _ room: Room) {
            self.parent = mediaPickerController
        }
        
        // MARK: Media Picker Delegate
        func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
            handleMediaItems(mediaItemCollection.items)
            mediaPicker.dismiss(animated: true)
        }
        func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
            mediaPicker.dismiss(animated: true)
        }
        
        func handleMediaItems(_ mediaItems: [MPMediaItem]) {
            for eachMediaItem in mediaItems {
                Task {
                    let song = await getSong(eachMediaItem)
                    
                    if song != nil {
                        // Add the song to the local queue
                        if parent.isHost {
                            do {
                                try await SystemMusicPlayer.shared.queue.insert(song!, position: parent.room.selectedPlayType == .next ? .afterCurrentEntry : .tail)
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                        
                        // Upload the song to the server
                        uploadQueueSong(song: song!, zoneID: parent.room.zone.zoneID, adderName: parent.room.share.currentUserParticipant?.userIdentity.nameComponents?.formatted() ?? "the host", playType: parent.room.selectedPlayType, database: parent.database) { (_ saveResult: Result<CKRecord, Error>) -> Void in
                            switch saveResult {
                                
                            case .success(let record):
                                let newQueueSong = QueueSong(song: try! JSONDecoder().decode(Song.self, from: record["Song"] as! Data), playType: record["PlayType"] as! String == "Next" ? .next : .later, adderName: record["AdderName"] as! String, timeAdded: record["TimeAdded"] as! Date, artwork: record["Artwork"] as! CKAsset)
                                
                                if let index = self.parent.room.queueSongs.firstIndex(where: { $0.timeAdded < record["TimeAdded"] as! Date }) {
                                    self.parent.room.queueSongs.insert(newQueueSong, at: index)
                                } else {
                                    self.parent.room.queueSongs.append(newQueueSong)
                                }
                                
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
        
        @Sendable func getSong(_ mediaItem: MPMediaItem) async -> Song? {
            do {
                var searchRequest = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(mediaItem.playbackStoreID))
                searchRequest.limit = 1
                return try await searchRequest.response().items[0]
            } catch {
                do {
                    return try await MusicCatalogSearchRequest(term: mediaItem.title!, types: [Song.self]).response().songs[0]
                } catch {
                    print(error.localizedDescription)
                }
            }
            return nil
        }
        
    }
    
 }
