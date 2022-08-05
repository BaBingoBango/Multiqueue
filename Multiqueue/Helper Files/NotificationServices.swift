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
import CloudKit

func showSongAddedNotification(adderName: String, songTitle: String, artistName: String, songArtworkURL: URL?, playType: PlayType, userName: String, roomName: String) {
    // Set the basic content for the notification
    var content = UNMutableNotificationContent()
    content.body = "\"\(songTitle)\" by \(artistName) was just added to play \(playType == .next ? "next" : "later")!"
    content.sound = UNNotificationSound.default
    
    // Attempt to set the attachment for the notification
//    do {
//        content.attachments = [try UNNotificationAttachment(identifier: "\(songTitle) by \(artistName) Artwork", url: songArtworkURL!)]
//    } catch {
//        print(error.localizedDescription)
//    }
    
    // Configure the notification's recipient
    let user = INPerson(
        personHandle: INPersonHandle(value: nil, type: .unknown),
        nameComponents: {
            var nameComponents = PersonNameComponents()
            nameComponents.nickname = userName
            return nameComponents
        }(),
        displayName: userName,
        image: nil,
        contactIdentifier: nil,
        customIdentifier: nil,
        isMe: true,
        suggestionType: .none
    )
    
    // Create an image for the sender
    let senderImage: INImage = {
        let gradientWhite = UIColor(red: 165.0 / 255.0, green: 169.0 / 255.0, blue: 182.0 / 255.0, alpha: 1)
        let gradientGray = UIColor(red: 136.0 / 255.0, green: 140.0 / 255.0, blue: 150.0 / 255.0, alpha: 1)
        
        let initialsImage: UIImageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        initialsImage.setImageForName(adderName, gradientColors: (gradientWhite, gradientGray), circular: true, textAttributes: [NSAttributedString.Key.font: {
            let fontSize: CGFloat = 24
            let systemFont = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
            if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
                return UIFont(descriptor: descriptor, size: fontSize)
            } else {
                return UIFont.systemFont(ofSize: fontSize, weight: .bold)
            }
        }(), NSAttributedString.Key.foregroundColor: UIColor.white])
        return INImage(imageData: initialsImage.image!.pngData()!)
    }()
    
    // Configure the notification's sender
    let sender = INPerson(
        personHandle: INPersonHandle(value: nil, type: .unknown),
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
        recipients: [sender, user],
        outgoingMessageType: .unknown,
        content: "content!",
        speakableGroupName: INSpeakableString(spokenPhrase: roomName),
        conversationIdentifier: roomName,
        serviceName: nil,
        sender: sender,
        attachments: nil
    )
    intent.setImage(senderImage, forParameterNamed: \.speakableGroupName)
    
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
    
    // Delete the artwork to save space
    if songArtworkURL != nil {
        do {
            try FileManager.default.removeItem(at: songArtworkURL!)
        } catch {
            print(error.localizedDescription)
        }
    }
}
