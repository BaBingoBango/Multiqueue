//
//  SearchAdder.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/18/22.
//

import SwiftUI
import MusicKit

struct CloudKitSearchAdder: View {
    
    @EnvironmentObject var multipeerServices: MultipeerServices
    @State var searchText = ""
    @Environment(\.presentationMode) var presentationMode
    @State var searchResults = MusicItemCollection<Song>()
    @Binding var room: Room
    var database: CloudKitDatabase
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    
                    Picker("Choose a Play Type", selection: $multipeerServices.playType) {
                        ForEach(multipeerServices.playTypes, id: \.self) { playType in
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
                                CloudKitButtonSongRowView(song: song, artwork: song.artwork!, room: $room, database: database).environmentObject(multipeerServices)
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
    
    func searchForSongsProxy() {
        Task {
            await searchForSongs()
        }
    }
    
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

//struct CloudKitSearchAdder_Previews: PreviewProvider {
//    static var previews: some View {
//        CloudKitSearchAdder().environmentObject(MultipeerServices(isHost: true))
//    }
//}
