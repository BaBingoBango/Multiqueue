//
//  NotificationService.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 8/2/22.
//

import Foundation
import UserNotifications

func showSongAddedNotification() {
    let content = UNMutableNotificationContent()
    content.title = "AWOOGA!!"
    content.subtitle = "Hello, notification!!"
    content.badge = 1
    content.body = "What up body????! Oh yeah!!!!"
    content.sound = UNNotificationSound.default

    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
    UNUserNotificationCenter.current().add(request)
}
