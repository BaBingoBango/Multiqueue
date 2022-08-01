//
//  NotificationStatus.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 7/31/22.
//

import Foundation

/// The status of the app's push notification response.
enum NotificationStatus {
    /// The case in which a notification is not currently being handled.
    case noNotification
    
    /// The case in which a notification is currently being handled.
    case responding
    
    /// The case in which a notification was handled and new data was downloaded.
    case successWithNewData
    
    /// The case in which a notification was handled but no new data was downloaded.
    case successWithoutNewData
    
    /// The case in which a notification was handled but the data download failed.
    case failure
}
