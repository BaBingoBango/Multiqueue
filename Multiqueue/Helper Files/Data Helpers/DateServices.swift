//
//  DateServices.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 8/3/22.
//

import Foundation

/// Converts an amount of seconds to its amount in hours, minutes, and seconds.
/// - Parameter seconds: The amount of seconds to convert.
/// - Returns: The hour, minute, and second values, in that order.
func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}
