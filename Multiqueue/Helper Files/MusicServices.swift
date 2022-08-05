//
//  MusicServices.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 7/30/22.
//

import Foundation
import MusicKit

var testSongs: [QueueSong] = []

var systemPlayingSong: Song? {
    if SystemMusicPlayer.shared.queue.currentEntry == nil {
        return nil
    } else {
        switch SystemMusicPlayer.shared.queue.currentEntry!.item! {
        case .song(let song):
            return song
        case .musicVideo(let musicVideo):
            return musicVideo.songs?.first
        @unknown default:
            return nil
        }
    }
}
var systemPlayingSongTitle: String {
    SystemMusicPlayer.shared.queue.currentEntry?.title ?? "No Current Song"
}
var systemPlayingSongArtist: String {
    SystemMusicPlayer.shared.queue.currentEntry?.description.components(separatedBy: "artistName: \"")[1].components(separatedBy: "\"))")[0] ?? ""
}
var systemPlayingSongArtwork: Artwork? {
    SystemMusicPlayer.shared.queue.currentEntry?.artwork
}
var systemPlayingSongTime: (Double, Double) {
    if SystemMusicPlayer.shared.queue.currentEntry == nil {
        return (0, 0)
    } else {
        let currentTime = Double(SystemMusicPlayer.shared.playbackTime)
        
        switch SystemMusicPlayer.shared.queue.currentEntry!.item! {
        case .song(let song):
            return (currentTime, Double(song.duration!))
        case .musicVideo(let musicVideo):
            return (currentTime, Double(musicVideo.duration!))
        @unknown default:
            return (0, 0)
        }
    }
}
