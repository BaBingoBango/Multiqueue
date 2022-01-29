//
//  SongRowView.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/9/22.
//

import SwiftUI
import MusicKit

struct SongRowView: View {
    
    var title: String
    var subtitle: String
    var artwork: Artwork?
    var subsubtitle: String?
    @State var searchResults = MusicItemCollection<Song>()
    
    var body: some View {
        VStack {
            HStack {
                if title != "Not Pl" && artwork != nil {
                    AsyncImage(url: URL(string: artwork!.url(width: 50, height: 50)!.absoluteString))
                        .frame(width: 50, height: 50)
                        .cornerRadius(5)
                } else {
                    Image(systemName: "play.square")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    Text(subtitle)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            
            HStack {
                if subsubtitle != nil {
                    Text(subsubtitle!)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            
        }
        .padding()
        .modifier(RectangleWrapper())
        .padding(.horizontal)
        .onAppear {
            
        }
    }
}

//struct SongRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        SongRowView(title: "Preview Song", subtitle: "Preview Artist")
//    }
//}
