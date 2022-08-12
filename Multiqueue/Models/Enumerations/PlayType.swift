//
//  PlayType.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 8/7/22.
//

import Foundation

/// A type of queue insertion that the Music app supports.
enum PlayType: Codable {
    /// Inserting the new song to play after the current song.
    case next
    
    /// Inserting the new song to play after all the songs in the queue.
    case later
}
