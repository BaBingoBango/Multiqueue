//
//  NotificationService.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 8/2/22.
//

import Foundation
import UserNotifications
import Intents
import UIKit

func showSongAddedNotification(adderName: String, songTitle: String, playType: PlayType, adderEmail: String?, userEmail: String, userName: String, roomName: String) {
    // Set the content for the notification
    var content = UNMutableNotificationContent()
    content.title = "Multiqueue"
    content.subtitle = "Song Added To Queue"
    content.badge = 1
    content.body = "\(adderName) just added \"\(songTitle)\" to play \(playType == .next ? "next" : "later")!"
    content.sound = UNNotificationSound.default
    
    // Configure the notification's receipient
    let user = INPerson(
        personHandle: INPersonHandle(value: userEmail, type: .emailAddress),
        nameComponents: {
            var nameComponents = PersonNameComponents()
            nameComponents.nickname = userName
            return nameComponents
        }(),
        displayName: userName,
        image: {
            let initialsImage: UIImageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            initialsImage.setImageForName(userName, backgroundColor: .gray, circular: true, textAttributes: nil)
            return INImage(imageData: initialsImage.image!.pngData()!)
        }(),
        contactIdentifier: nil,
        customIdentifier: nil,
        isMe: true,
        suggestionType: .none
    )
    
    // Create an image for the sender
    let senderImage: INImage = {
        let initialsImage: UIImageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        initialsImage.setImageForName(adderName, backgroundColor: .gray, circular: true, textAttributes: nil)
        return INImage(imageData: initialsImage.image!.pngData()!)
    }()
    
    // Configure the notification's sender
    let sender = INPerson(
        personHandle: INPersonHandle(value: adderEmail, type: .emailAddress),
        nameComponents: {
            var nameComponents = PersonNameComponents()
            nameComponents.nickname = adderName
            return nameComponents
        }(),
        displayName: adderName,
        image: senderImage,
        contactIdentifier: nil,
        customIdentifier: nil,
        isMe: false,
        suggestionType: .none
    )
    
    // Create an intent object with the communciation info
    let intent = INSendMessageIntent(
        recipients: [user],
        outgoingMessageType: .unknown,
        content: "content!",
        speakableGroupName: INSpeakableString(spokenPhrase: roomName),
        conversationIdentifier: roomName,
        serviceName: nil,
        sender: sender,
        attachments: nil
    )
    intent.setImage(senderImage, forParameterNamed: \.sender)
    
    // Configure an interaction object for the intent
    let interaction = INInteraction(intent: intent, response: nil)
    interaction.direction = .incoming
    interaction.donate(completion: nil)

    // Update the notification with the intent
    do {
        content = try content.updating(from: intent) as! UNMutableNotificationContent
    } catch {
        print(error.localizedDescription)
    }
    
    // Display the notification
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
    UNUserNotificationCenter.current().add(request)
}
