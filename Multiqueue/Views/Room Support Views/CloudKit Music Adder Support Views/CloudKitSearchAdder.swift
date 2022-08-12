//
//  SearchAdder.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/18/22.
//

import SwiftUI
import MusicKit

/// A view that can add songs to a room by searching Apple Music.
struct CloudKitSearchAdder: View {
    
    // MARK: - View Variables
    /// The search text entered by the user.
    @State var searchText = ""
    /// The `PresentationMode` variable for this view.
    @Environment(\.presentationMode) var presentationMode
    /// The MusicKit search results for the entered search text on this view.
    @State var searchResults = MusicItemCollection<Song>()
    /// The room this view can upload to.
    @Binding var room: Room
    /// The database to use for uploads from this view.
    var database: CloudKitDatabase
    /// Whether or not this user is the host.
    var isHost: Bool
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            ScrollView {
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
                    .padding(.bottom, 10)
                    
                    SearchBar(text: $searchText, placeholder: "Search Apple Music Songs...")
                    .onChange(of: searchText) { newValue in
                        searchForSongsProxy()
                    }
                    
                    if !searchResults.isEmpty {
                        
                        HeadingText(text: searchResults.count == 1 ? "Search Result" : "Search Results")
                            .padding(.top)
                        
                        ForEach(searchResults) { song in
                            Button(action: {}) {
                                CloudKitButtonSongRowView(song: song, artwork: song.artwork!, room: $room, database: database, isHost: isHost)
                            }
                        }
                        
                    }
                    
                    Spacer()
                    
                }
                
            }
            
            // MARK: - Navigation Bar Settings
            .navigationBarItems(trailing: Button(action: { self.presentationMode.wrappedValue.dismiss() }) { Text("Done").fontWeight(.bold) })
            .navigationBarTitle("Add from Search", displayMode: .inline)
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    /// A helper function which calls the function that searches MusicKit for songs.
    func searchForSongsProxy() {
        Task {
            await searchForSongs()
        }
    }
    
    /// Searches MusicKit for songs.
    @Sendable func searchForSongs() async {
        do {
            
            var searchRequest = MusicCatalogSearchRequest(term: searchText, types: [Song.self])
            searchRequest.limit = 25
            try await searchResults = searchRequest.response().songs
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
