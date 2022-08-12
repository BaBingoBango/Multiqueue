//
//  CloudKitDatabase.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 7/31/22.
//

import Foundation

/// A type of CloudKit database.
enum CloudKitDatabase {
    /// The public CloudKit database.
    case publicDatabase
    
    /// The private CloudKit database.
    case privateDatabase
    
    /// The shared CloudKit database.
    case sharedDatabase
}
