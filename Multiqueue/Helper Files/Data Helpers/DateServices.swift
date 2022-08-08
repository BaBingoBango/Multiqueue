//
//  DateServices.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 8/3/22.
//

import Foundation

func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}
