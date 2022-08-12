//
//  MusicAdder.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/9/22.
//

import SwiftUI
import MusicKit

/// A tab view that provides options for songs to be added to a room.
struct CloudKitMusicAdder: View {
    
    // MARK: - View Variables
    /// The currently selected tab on this view.
    @State var selectedTab = 0
    /// The room this view can upload to.
    @Binding var room: Room
    /// Whether or not the library picker is being presented.
    @Binding var isShowingLibraryPicker: Bool
    /// The database this view should upload to.
    var database: CloudKitDatabase
    /// Whether or not this user is a host
    var isHost: Bool
    
    // MARK: - View Body
    var body: some View {
        TabView(selection: $selectedTab) {
            
            CloudKitLibraryAdder(isShowingLibraryPicker: $isShowingLibraryPicker, room: $room, isHost: isHost, database: database)
                .tabItem {
                VStack {
                    Image(systemName: "music.note.house.fill")
                    Text("Library")
                }
            }.tag(1)
            
            CloudKitSearchAdder(room: $room, database: database, isHost: isHost).tabItem {
                VStack {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            }.tag(2)
            
            CloudKitLinkAdder(room: $room, database: database, isHost: isHost).tabItem {
                VStack {
                    Image(systemName: "link")
                    Text("Link")
                }
            }.tag(3)
            
        }
    }
    
}
