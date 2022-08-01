//
//  LinkAdder.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/18/22.
//

import SwiftUI
import MusicKit

struct CloudKitLinkAdder: View {
    
    @EnvironmentObject var multipeerServices: MultipeerServices
    @State var linkText = ""
    @State var linkResults = MusicItemCollection<Song>()
    @Environment(\.presentationMode) var presentationMode
    var linkID: String {
        let components = URLComponents(string: linkText)
        guard let songID = components?.queryItems?.first?.value else { return "" }
        return songID
    }
    @Binding var room: Room
    
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
                                CloudKitButtonSongRowView(song: song, artwork: song.artwork!, room: $room).environmentObject(multipeerServices)
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
    
    func getLinkResultProxy() {
        Task {
            await getLinkResult()
        }
    }
    
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

//struct CloudKitLinkAdder_Previews: PreviewProvider {
//    static var previews: some View {
//        CloudKitLinkAdder().environmentObject(MultipeerServices(isHost: true))
//    }
//}
