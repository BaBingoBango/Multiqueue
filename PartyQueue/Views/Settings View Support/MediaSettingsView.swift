//
//  MediaSettingsView.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/21/22.
//

import SwiftUI
import MusicKit

struct MediaSettingsView: View {
    var body: some View {
        ScrollView {
            VStack {
                
                HStack {
                    Image(systemName: "music.note.house.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.secondary)
                        .hidden()
                    Image(systemName: "music.note.house.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.accentColor)
                    Image(systemName: "music.note.house.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.secondary)
                        .hidden()
                }
                .padding([.top, .leading, .trailing])
                
                Text("Media & Apple Music Access")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                if MusicAuthorization.currentStatus == .authorized {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                            .foregroundColor(.green)
                        Text("You've granted PartyQueue Media & Apple Music access. To revoke access, visit Settings > Privacy > Media & Apple Music.")
                        Spacer()
                    }
                    .padding([.top, .leading, .bottom])
                    .modifier(RectangleWrapper(color: .green))
                    .padding(.horizontal)
                } else {
                    HStack {
                        Image(systemName: "exclamationmark.octagon.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                            .foregroundColor(.red)
                        Text("You haven't given PartyQueue Media & Apple Music access. To grant access, visit Settings > Privacy > Media & Apple Music.")
                        Spacer()
                    }
                    .padding([.top, .leading, .bottom])
                    .modifier(RectangleWrapper(color: .red))
                    .padding(.horizontal)
                }
                
                HStack {
                    Text("About Media & Apple Music Usage")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding([.top, .leading])
                
                HStack {
                    Text("Apple Music is normally accessed through the Music app on Apple devices. As a third-party app, in order to interface with the Music app and the Apple Music catalog, PartyQueue uses Apple's MusicKit framework.\n\nIn this case, PartyQueue uses MusicKit to accomplish a number of important app functions: adding songs to the host device's music queue, accessing a device's music library, searching the Apple Music catalog, and following Apple Music song links.\n\nFor privacy reasons, Apple requires users explicity approve MusicKit access. You can grant or revoke this approval at any time in the Settings app.")
                        .multilineTextAlignment(.leading)
                        .offset(y: 5)
                    Spacer()
                }
                .padding(.leading)
                
            }
        }
    }
}

struct MediaSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MediaSettingsView()
    }
}
