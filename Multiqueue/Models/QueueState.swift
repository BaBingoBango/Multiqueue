//
//  QueueState.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/9/22.
//

import Foundation
import MusicKit

struct QueueState: Codable {
    
    // MARK: - Variables
    var currentSong: SongState
    var addedToQueue: [QueueEntry]
    
}
