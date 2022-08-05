//
//  ButtonSongRowView.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/19/22.
//

import SwiftUI
import MusicKit

struct ButtonSongRowView: View {
    
    @EnvironmentObject var multipeerServices: MultipeerServices
    var song: Song
    @State var showPlus = true
    var artwork: Artwork
    
    var body: some View {
        HStack {
            if song.title != "Not Pl" {
                AsyncImage(url: URL(string: artwork.url(width: 50, height: 50)!.absoluteString))
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
            
            Image(systemName: showPlus ? "plus.circle" : "checkmark")
                .foregroundColor(.accentColor)
                .imageScale(.large)
        }
        .padding()
        .modifier(RectangleWrapper())
        .padding(.horizontal)
        .onTapGesture {
            multipeerServices.addSongsToQueueState(songs: [song])
            showPlus = false
        }
    }
}

//struct ButtonSongRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        ButtonSongRowView(title: "Preview Title", subtitle: "Preview Artist", showPlus: true).environmentObject(MultipeerServices(isHost: false))
//    }
//}
