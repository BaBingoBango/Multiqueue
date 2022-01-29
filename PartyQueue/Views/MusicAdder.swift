//
//  MusicAdder.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/9/22.
//

import SwiftUI
import MusicKit

struct MusicAdder: View {
    
    @EnvironmentObject var multipeerServices: MultipeerServices
    @State var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            LibraryAdder()
                .environmentObject(multipeerServices)
                .tabItem {
                VStack {
                    Image(systemName: "music.note.house.fill")
                    Text("Library")
                }
            }.tag(1)
            
            SearchAdder().environmentObject(multipeerServices).tabItem {
                VStack {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            }.tag(2)
            
            LinkAdder().environmentObject(multipeerServices).tabItem {
                VStack {
                    Image(systemName: "link")
                    Text("Link")
                }
            }.tag(3)
            
        }
    }
    
}

struct MusicAdder_Previews: PreviewProvider {
    static var previews: some View {
        MusicAdder().environmentObject(MultipeerServices(isHost: true))
    }
}

//@Sendable func requestTestSongAsync() async {
//    do {
//        let answer = try await MusicCatalogSearchRequest(term: "She Bangs (English Version)", types: [Song.self]).response().songs[0]
//        multipeerServices.queueState.addedToQueue.append(QueueEntry(song: answer, timeAdded: Date(), adder: multipeerServices.session.myPeerID.displayName, playType: .later))
//        print("(1) Updated local queue state to a queueState with \(multipeerServices.queueState.addedToQueue.count) added to queue!")
//        
//        // Send the new queueState to all other devices
//        do {
//            try multipeerServices.session.send(JSONEncoder().encode(multipeerServices.queueState), toPeers: multipeerServices.session.connectedPeers, with: .reliable)
//            print("(2) Succesfully sent queue state!")
//        } catch {
//            print("Error sending queue state from MusicAdder.swift!")
//            print(error.localizedDescription)
//        }
//        
//        // If the device is the host, update the system music queue
//        if multipeerServices.isHost {
//            @Sendable func updateSystemQueueAsync() async {
//                do {
//                    try await SystemMusicPlayer.shared.queue.insert(multipeerServices.queueState.addedToQueue.last!.song, position: multipeerServices.queueState.addedToQueue.last!.playType == .next ? .afterCurrentEntry : .tail)
//                } catch {
//                    print("Error in adding to system music player queue!")
//                    print(error.localizedDescription)
//                }
//            }
//            func updateSystemQueue() {
//                Task {
//                    await updateSystemQueueAsync()
//                }
//            }
//            updateSystemQueue()
//        }
//        
//    } catch {
//        print(error.localizedDescription)
//    }
//}
