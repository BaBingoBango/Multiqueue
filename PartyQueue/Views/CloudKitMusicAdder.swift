//
//  MusicAdder.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/9/22.
//

import SwiftUI
import MusicKit

struct CloudKitMusicAdder: View {
    
    @State var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            CloudKitLibraryAdder()
                .tabItem {
                VStack {
                    Image(systemName: "music.note.house.fill")
                    Text("Library")
                }
            }.tag(1)
            
            CloudKitSearchAdder().tabItem {
                VStack {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            }.tag(2)
            
            CloudKitLinkAdder().tabItem {
                VStack {
                    Image(systemName: "link")
                    Text("Link")
                }
            }.tag(3)
            
        }
    }
    
}

struct CloudKitMusicAdder_Previews: PreviewProvider {
    static var previews: some View {
        CloudKitMusicAdder().environmentObject(MultipeerServices(isHost: true))
    }
}
