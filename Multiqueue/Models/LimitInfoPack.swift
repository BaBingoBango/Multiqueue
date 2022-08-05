//
//  LimitInfoPack.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/23/22.
//

import Foundation

struct LimitInfoPack: Codable {
    
    var isTimeLimit: Bool
    var timeLimit: Int
    var isSongLimit: Bool
    var songLimit: Int
    
}
