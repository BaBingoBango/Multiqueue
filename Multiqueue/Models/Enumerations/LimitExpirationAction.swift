//
//  LimitExpirationAction.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 8/3/22.
//

import Foundation

/// An action that can occur after a Song Limit or Time Limit expires.
enum LimitExpirationAction {
    /// Nothing happens when the limit expires.
    case nothing
    
    /// The room is deactivated when the limit expires.
    case deactivateRoom
    
    /// All participants are removed from the room when the limit expires.
    case removeParticipants
    
    /// The room is deleted when the limit expires.
    case deleteRoom
}

/// Converts a properly formatted string into a `LimitExpirationAction` enumeration.
/// - Parameter string: The string to convert.
/// - Returns: The converted `LimitExpirationAction` enumeration.
func convertStringToLimitExpirationAction(_ string: String) -> LimitExpirationAction {
    if string == "Deactivate Room" {
        return .deactivateRoom
    } else if string == "Remove Participants" {
        return .removeParticipants
    } else if string == "Delete Room" {
        return .deleteRoom
    } else {
        return .nothing
    }
}

/// Converts a `LimitExpirationAction` enumeration into a properly formatted string.
/// - Parameter action: The `LimitExpirationAction` enumeration to convert.
/// - Returns: The converted string.
func convertLimitExpirationActionToString(_ action: LimitExpirationAction) -> String {
    switch action {
    case .nothing:
        return "Nothing"
    case .deactivateRoom:
        return "Deactivate Room"
    case .removeParticipants:
        return "Remove Participants"
    case .deleteRoom:
        return "Delete Room"
    }
}
