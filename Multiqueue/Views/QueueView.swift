//
//  QueueView.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/4/22.
//

import SwiftUI
import MusicKit
import simd

struct QueueView: View {
    
    @EnvironmentObject var multipeerServices: MultipeerServices
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State var timerCheck = 0
    let timeLimitTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    @State var showingMusicAdder = false
    @State var searchResults = MusicItemCollection<Song>()
    @State var showingSettings = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    
                    HStack {
                        Text($multipeerServices.connectedDevices.count != 1 ? "\($multipeerServices.connectedDevices.count) Devices Connected" : "\($multipeerServices.connectedDevices.count) Device Connected")
                            .font(.headline)
                        Spacer()
                    }
                    .padding(.leading, 22)
                    
                    if multipeerServices.isSongLimit {
                        HStack {
                            Text("\(multipeerServices.songLimit) \(multipeerServices.songLimit == 1 ? "Song" : "Songs") Left")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.leading, 22)
                    }
                    
                    if multipeerServices.isTimeLimit {
                        HStack {
                            Text("\(multipeerServices.timeLimit) \(multipeerServices.timeLimit == 1 ? "Minute" : "Minutes") Left")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.leading, 22)
                    }
                    
                    HStack {
                        Text("Current Song")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding([.top, .leading])
                    
                    SongRowView(title: multipeerServices.queueState.currentSong.title, subtitle: multipeerServices.queueState.currentSong.artist)
                    
                    Image(systemName: "arrow.up")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .padding(.top)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Recently Added to Queue")
                                .font(.title2)
                                .fontWeight(.bold)
//                            Text("Please use the Music app to re-order the queue and to delete items from it.")
                                .font(.footnote)
                        }
                        Spacer()
                    }
                    .padding([.top, .leading])
                    
                    ForEach(multipeerServices.queueState.addedToQueue.reversed(), id: \.self) { entry in
                        SongRowView(title: entry.song.title, subtitle: entry.song.artistName, artwork: entry.song.artwork!, subsubtitle: "Added for \(entry.playType == .next ? "next" : "later") by \"\(entry.adder)\" at \(entry.timeAdded.formatted(date: .omitted, time: .standard))")
                    }
                    .onChange(of: multipeerServices.queueState.addedToQueue) { newValue in
                        if multipeerServices.isSongLimit && multipeerServices.songLimit >= 1 {
                            multipeerServices.songLimit -= 1
                            if multipeerServices.songLimit == 0 {
                                multipeerServices.stopBrowsing()
                                multipeerServices.isReceivingData = false
                                multipeerServices.session.disconnect()
                                multipeerServices.connectedDevices = []
                                multipeerServices.discoveredDevices = []
                                multipeerServices.queueState = QueueState(currentSong: SongState(title: SystemMusicPlayer.shared.queue.currentEntry?.title ?? "No Current Song", artist: SystemMusicPlayer.shared.queue.currentEntry?.description.components(separatedBy: "artistName: \"")[1].components(separatedBy: "\"))")[0] ?? ""), addedToQueue: [])
                                self.presentationMode.wrappedValue.dismiss()
                                multipeerServices.isSongLimit = false
                                multipeerServices.isTimeLimit = false
                            }
                        }
                    }
                    
                }
            }
            
            Button(action: {
                showingMusicAdder.toggle()
            }) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.accentColor)
                        .cornerRadius(15)
                        .frame(height: 55)
                    Text("Add Song to Queue")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .padding([.top, .leading, .trailing])
            .sheet(isPresented: $showingMusicAdder) {
                MusicAdder().environmentObject(multipeerServices)
            }
            
        }
        .onReceive(timer) { time in
            timerCheck += 1;
            searchForSongsProxy()
            // If this is the host, update and transmit the current songState if it's different than the current one
            if multipeerServices.isHost && ((multipeerServices.queueState.currentSong.title != SystemMusicPlayer.shared.queue.currentEntry?.title ?? "No Current Song") || (multipeerServices.queueState.currentSong.artist != SystemMusicPlayer.shared.queue.currentEntry?.description.components(separatedBy: "artistName: \"")[1].components(separatedBy: "\"))")[0] ?? "No Current Artist")) {
                
                multipeerServices.queueState.currentSong = SongState(title: SystemMusicPlayer.shared.queue.currentEntry?.title ?? "No Current Song", artist: SystemMusicPlayer.shared.queue.currentEntry?.description.components(separatedBy: "artistName: \"")[1].components(separatedBy: "\"))")[0] ?? "")
                do {
                    try multipeerServices.session.send(JSONEncoder().encode(multipeerServices.queueState), toPeers: multipeerServices.session.connectedPeers, with: .reliable)
                    print("(2) Succesfully sent queue state!")
                } catch {
                    print("Error sending queue state from QueueView.swift!")
                    print(error.localizedDescription)
                }
                
            }
            
            if (multipeerServices.isHost && timerCheck == 100) {
                timerCheck = 0
                do {
                    try multipeerServices.session.send(JSONEncoder().encode(LimitInfoPack(isTimeLimit: multipeerServices.isTimeLimit, timeLimit: multipeerServices.timeLimit, isSongLimit: multipeerServices.isSongLimit, songLimit: multipeerServices.songLimit)), toPeers: multipeerServices.session.connectedPeers, with: .reliable)
                } catch {
                    print(error.localizedDescription)
                }
            }
            
        }
        .onReceive(timeLimitTimer) { time in
            if multipeerServices.isTimeLimit && multipeerServices.timeLimit >= 1 {
                multipeerServices.timeLimit -= 1
                if multipeerServices.timeLimit == 0 {
                    multipeerServices.stopBrowsing()
                    multipeerServices.isReceivingData = false
                    multipeerServices.session.disconnect()
                    multipeerServices.connectedDevices = []
                    multipeerServices.discoveredDevices = []
                    multipeerServices.queueState = QueueState(currentSong: SongState(title: SystemMusicPlayer.shared.queue.currentEntry?.title ?? "No Current Song", artist: SystemMusicPlayer.shared.queue.currentEntry?.description.components(separatedBy: "artistName: \"")[1].components(separatedBy: "\"))")[0] ?? ""), addedToQueue: [])
                    self.presentationMode.wrappedValue.dismiss()
                    multipeerServices.isSongLimit = false
                    multipeerServices.isTimeLimit = false
                }
            }
        }
        .onAppear {
            searchForSongsProxy()
        }
        .navigationBarItems(trailing: QueueSettingsButton(showingSettings: $showingSettings).environmentObject(multipeerServices))
        .sheet(isPresented: $showingSettings) {
            NavigationView {
                QueueSettings().environmentObject(multipeerServices)
                    .navigationBarTitle("Session Settings", displayMode: .inline)
            }
        }
            
    }
    
    func searchForSongsProxy() {
        Task {
            await searchForSongs()
        }
    }
    
    @Sendable func searchForSongs() async {
        do {
            
            var searchRequest = MusicCatalogSearchRequest(term: multipeerServices.queueState.currentSong.title, types: [Song.self])
            searchRequest.limit = 25
            try await searchResults = searchRequest.response().songs
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

struct QueueView_Previews: PreviewProvider {
    static var previews: some View {
        QueueView().environmentObject(MultipeerServices(isHost: true))
    }
}

struct QueueSettingsButton: View {
    @EnvironmentObject var multipeerServices: MultipeerServices
    @Binding var showingSettings: Bool
    var body: some View {
        if multipeerServices.isHost {
            Button(action: { showingSettings.toggle() }) { Image(systemName: "gear") }
        } else {
            Button(action: { showingSettings.toggle() }) { Image(systemName: "gear") }.hidden()
        }
    }
}
