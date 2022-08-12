//
//  SongRowView.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/9/22.
//

import SwiftUI
import MusicKit
import CloudKit

// MARK: - View Variables
/// A list row view for a song in room views.
struct SongRowView: View {
    
    /// A type of `SongRowView`
    enum SongRowViewMode {
        /// A `SongRowView` showing just the song.
        case songOnly
        
        /// A `SongRowView` showing the song and a time bar.
        case withTimeBar
        
        /// A `SongRowView` showing the song, a time bar, and song controls.
        case withSongControls
    }
    
    /// The title to place in this view.
    var title: String
    /// The subtitle to place in this view.
    var subtitle: String
    /// Artwork to place in this view.
    var artwork: Artwork?
    /// Custom artwork to override the `artwork` property in this view.
    var customArtwork: CKAsset?
    /// A sub-subtitle to place in this view.
    var subsubtitle: String?
    /// MusicKit search results for this view.
    @State var searchResults = MusicItemCollection<Song>()
    
    /// The display mode for this view.
    var mode = SongRowViewMode.songOnly
    /// The time to insert in the time bar, if it is showing.
    ///
    /// The first value is the time elapsed, while the second value is the total time.
    var nowPlayingTime: (Double, Double)?
    
    // MARK: - View Body
    var body: some View {
        VStack {
            HStack {
                if customArtwork != nil {
                    AsyncImage(
                        url: customArtwork!.fileURL,
                        content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .cornerRadius(5)
                        },
                        placeholder: {
                            Image(systemName: "play.square")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                    )
                } else {
                    if title != "Not Pl" && artwork != nil {
                        AsyncImage(
                            url: artwork!.url(width: 50, height: 50),
                            content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(5)
                            },
                            placeholder: {
                                Image(systemName: "play.square")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                            }
                        )
                    } else {
                        Image(systemName: "play.square")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
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
            
            if mode != .songOnly {
                ProgressView(value: nowPlayingTime!.0 / nowPlayingTime!.1)
                    .progressViewStyle(LinearProgressViewStyle())
                
                HStack {
                    let timePassed = Int(nowPlayingTime!.0.rounded())
                    let minutesPassed = timePassed / 60
                    let secondsPassed = timePassed % 60
                    
                    Text("\(minutesPassed):\(secondsPassed < 10 ? "0\(secondsPassed)" : String(secondsPassed))")
                        .foregroundColor(.secondary)
                        .font(.callout)
                    
                    Spacer()
                    
                    let timeRemaining = Int(nowPlayingTime!.1 - nowPlayingTime!.0.rounded())
                    let minutesLeft = timeRemaining / 60
                    let secondsLeft = timeRemaining % 60
                    
                    Text("-\(minutesLeft):\(secondsLeft < 10 ? "0\(secondsLeft)" : String(secondsLeft))")
                        .foregroundColor(.secondary)
                        .font(.callout)
                }
                
                if mode == .withSongControls {
                    HStack(spacing: 0) {
                        Spacer()
                        
                        Button(action: {
                            if nowPlayingTime!.0 >= 5 {
                                SystemMusicPlayer.shared.restartCurrentEntry()
                            } else {
                                DispatchQueue.main.async {
                                    Task {
                                        do {
                                            try await SystemMusicPlayer.shared.skipToPreviousEntry()
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    }
                                }
                            }
                        }) {
                            Image(systemName: "backward.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.primary)
                                .frame(width: 30, height: 30)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if SystemMusicPlayer.shared.state.playbackStatus == .playing {
                                SystemMusicPlayer.shared.pause()
                            } else {
                                DispatchQueue.main.async {
                                    Task {
                                        do {
                                            try await SystemMusicPlayer.shared.play()
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    }
                                }
                            }
                        }) {
                            Image(systemName: SystemMusicPlayer.shared.state.playbackStatus == .playing ? "pause.fill" : "play.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.primary)
                                .frame(width: 30, height: 30)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            DispatchQueue.main.async {
                                Task {
                                    do {
                                        try await SystemMusicPlayer.shared.skipToNextEntry()
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                        }) {
                            Image(systemName: "forward.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.primary)
                                .frame(width: 30, height: 30)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom)
                }
            }
        }
        .padding()
        .modifier(RectangleWrapper())
        .padding(.horizontal)
    }
}
