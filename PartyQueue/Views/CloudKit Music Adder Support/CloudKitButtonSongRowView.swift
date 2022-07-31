//
//  ButtonSongRowView.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/19/22.
//

import SwiftUI
import MusicKit

struct CloudKitButtonSongRowView: View {
    
    var song: Song
    @State var showPlus = true
    var artwork: Artwork?
    
    var body: some View {
        HStack {
            if song.title != "Not Pl" && artwork != nil {
                AsyncImage(url: URL(string: artwork!.url(width: 50, height: 50)!.absoluteString))
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
            showPlus = false
        }
    }
}

//struct CloudKitButtonSongRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        CloudKitButtonSongRowView(song: Song(), title: "Preview Title", subtitle: "Preview Artist", artwork: nil, showPlus: true)
//    }
//}
