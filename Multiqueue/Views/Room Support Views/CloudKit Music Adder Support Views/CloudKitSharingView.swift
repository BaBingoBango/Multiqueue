//
//  CloudKitSharingView.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 7/29/22.
//

import Foundation
import SwiftUI
import UIKit
import CloudKit

/// A SwiftUI view for displaying the CloudKit sharing view for a room via a modal.
struct CloudKitSharingView: UIViewControllerRepresentable {
    // MARK: View Variables
    var room: Room
    var container: CKContainer
    
    // MARK: View Controller Generator
    func makeUIViewController(context: Context) -> UICloudSharingController {
        // MARK: Sharing View Settings
        let cloudSharingController = UICloudSharingController(share: room.share, container: container)
        
        cloudSharingController.modalPresentationStyle = .pageSheet
        cloudSharingController.availablePermissions = [.allowReadWrite]
        
        cloudSharingController.delegate = context.coordinator
        return cloudSharingController
    }
    
    // MARK: View Controller Updater
    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {
        
    }
    
    // MARK: Coordinator Generator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: Coordinator Class
    class Coordinator: NSObject, UICloudSharingControllerDelegate {
        var parent: CloudKitSharingView
        
        init(_ sharingView: CloudKitSharingView) {
            self.parent = sharingView
        }
        
        // MARK: Sharing View Delegate Functions
        func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
            csc.dismiss(animated: true)
        }
        
        func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
            print(error.localizedDescription)
            csc.dismiss(animated: true)
        }
        
        func itemTitle(for csc: UICloudSharingController) -> String? {
            parent.room.details.name
        }
        
        func itemThumbnailData(for csc: UICloudSharingController) -> Data? {
            return NSDataAsset(name: "Rounded App Icon")!.data
        }
    }
}
