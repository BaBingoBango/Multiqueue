//
//  QueueEntry.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/9/22.
//

import Foundation
import MultipeerConnectivity
import MusicKit

struct QueueEntry: Hashable, Codable {
    
    // MARK: - Variables
    var id = UUID()
    var song: Song
    var timeAdded: Date
    var adder: String
    var playType: PlayType
    
    // MARK: - Codable Compliance, Part 1
    enum CodingKeys: String, CodingKey {
        case id
        case song
        case timeAdded
        case adder
        case playType
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(song, forKey: .song)
        try container.encode(timeAdded, forKey: .timeAdded)
        try container.encode(adder, forKey: .adder)
        try container.encode(playType, forKey: .playType)
    }
    
}

// MARK: - Codable Compliance, Part 2
extension QueueEntry {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        song = try values.decode(Song.self, forKey: .song)
        timeAdded = try values.decode(Date.self, forKey: .timeAdded)
        adder = try values.decode(String.self, forKey: .adder)
        playType = try values.decode(PlayType.self, forKey: .playType)
    }
}

// MARK: - PlayType Enumeration
enum PlayType: Codable {
    case next
    case later
}
