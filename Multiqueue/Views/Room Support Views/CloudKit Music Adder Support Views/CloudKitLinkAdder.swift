//
//  LinkAdder.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/18/22.
//

import SwiftUI
import MusicKit

/// The view for adding songs to a room via an Apple Music link.
struct CloudKitLinkAdder: View {
    
    // MARK: - View Variables
    /// The entered text in the link text box.
    @State var linkText = ""
    /// The search results for the entered link.
    @State var linkResults = MusicItemCollection<Song>()
    /// The `PresentationMode` variable for this view.
    @Environment(\.presentationMode) var presentationMode
    /// The link ID from the entered text box text.
    var linkID: String {
        let components = URLComponents(string: linkText)
        guard let songID = components?.queryItems?.first?.value else { return "" }
        return songID
    }
    /// The room this view can upload to.
    @Binding var room: Room
    /// The database this view can upload to.
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
                    
                    HStack {
                        Image(systemName: "link")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.secondary)
                            .hidden()
                        Image(systemName: "link")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.secondary)
                        Image(systemName: "link")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.secondary)
                            .hidden()
                    }
                    .padding([.top, .leading, .trailing])
                    
                    SearchBar(text: $linkText, placeholder: "Enter Apple Music Song Link...")
                        .padding(.top)
                        .onChange(of: linkText) { newValue in
                            getLinkResultProxy()
                        }
                    
                    if !linkResults.isEmpty {
                        
                        HeadingText(text: "Link Result")
                            .padding(.top)
                        
                        ForEach(linkResults) { song in
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
            .navigationBarTitle("Add from Link", displayMode: .inline)
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    /// A helper function which calls the function that searches MusicKit for the song a link leads to.
    func getLinkResultProxy() {
        Task {
            await getLinkResult()
        }
    }
    
    /// Searches MusicKit for the song a link leads to.
    @Sendable func getLinkResult() async {
        do {
            
            var searchRequest = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(linkID))
            searchRequest.limit = 1
            try await linkResults = searchRequest.response().items
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
