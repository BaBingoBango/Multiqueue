//
//  MultiqueueApp.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/2/22.
//

import SwiftUI
import CloudKit
import MusicKit

/// A global variable for keeping track of the app's current `ScenePhase`.
var globalScenePhase: ScenePhase = .inactive

@main
struct MultiqueueApp: App {
    /// The system-provided `ScenePhase` object.
    @Environment(\.scenePhase) var scenePhase
    /// The persistence controller for Core Data.
    let persistenceController = PersistenceController.shared
    /// The custom app delegate for the app.
    @UIApplicationDelegateAdaptor var delegate: MultiqueueAppDelegate

    var body: some Scene {
        WindowGroup {
            // MARK: - App Entry Point
            MainMenu()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    // Disable Auto-Lock and register for push notifications
                    UIApplication.shared.isIdleTimerDisabled = true
                    UIApplication.shared.registerForRemoteNotifications()
                }
                .onChange(of: scenePhase) { newValue in
                    // Update the global scene phase variable when the scene phase changes
                    globalScenePhase = newValue
                }
        }
    }
}

#if os(iOS)
/// The custom app delegate class for the app.
class MultiqueueAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, ObservableObject {
    /// Whether or not a share is currently being accepted.
    @Published var isAcceptingShare = false
    /// The status of notification handling for the app.
    @Published var notificationStatus = NotificationStatus.noNotification
    /// The completion handler to call when the handling of the currently processing notification is complete.
    @Published var notificationCompletionHandler: ((UIBackgroundFetchResult) -> Void)?
    
    /// The function called to configure the app's custom scene delegate.
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = MultiqueueSceneDelegate.self
        return sceneConfig
    }
    
    /// The function called when a user opens a CloudKit share link on macOS or an iOS app that does not use scenes.
    func application(_ application: UIApplication, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        if cloudKitShareMetadata.participantStatus == .pending {
            self.isAcceptingShare = true
            let acceptShareOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])
            acceptShareOperation.acceptSharesResultBlock = { (_ result: Result<Void, Error>) -> Void in
                switch result {
                case .success():
                    self.isAcceptingShare = false
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    self.isAcceptingShare = false
                }
            }
            CKContainer(identifier: "iCloud.Multiqueue").add(acceptShareOperation)
        }
    }
    /// The "notification port" function; called when a push notification arrives from the server.
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("[\(Date().formatted(date: .omitted, time: .standard))] [SP: \(globalScenePhase)] Push notification received from the server!")
        
        // Update the app-wide notification status and completion handler
        notificationCompletionHandler = completionHandler
        notificationStatus = .responding
        
        // Add the song to the local queue now
        // Get the record and zone information from the notification
        if let cloudKitInfo = userInfo["ck"] as? [String: Any] {
            if let queryInfo = cloudKitInfo["qry"] as? [String: Any] {
                if let requestedKeys = queryInfo["af"] as? [String: Any] {
                    
                    let recordName = requestedKeys["RecordName"] as! String
                    let zoneName = requestedKeys["ZoneName"] as! String
                    let zoneOwnerName = requestedKeys["ZoneOwnerName"] as! String
                    
                    // Fetch the new song this notification was triggered by
                    let songFetchOperation = CKFetchRecordsOperation(recordIDs: [CKRecord.ID(recordName: recordName, zoneID: CKRecordZone.ID(zoneName: zoneName, ownerName: zoneOwnerName))])
                    
                    songFetchOperation.perRecordResultBlock = { (_ recordID: CKRecord.ID, _ recordResult: Result<CKRecord, Error>) -> Void in
                        switch recordResult {
                            
                        case .success(let record):
                            // Unpack the fetched record
                            let newSong = QueueSong(song: try! JSONDecoder().decode(Song.self, from: record["Song"] as! Data),
                                                    playType: {
                                let playTypeString = record["PlayType"] as! String
                                if playTypeString == "Next" {
                                    return .next
                                } else {
                                    return .later
                                }
                            }(),
                                                    adderName: record["AdderName"] as! String,
                                                    timeAdded: record["TimeAdded"] as! Date,
                                                    artwork: record["Artwork"] as! CKAsset)
                            
                            // Add the song to the system music queue
                            Task {
                                do {
                                    try await SystemMusicPlayer.shared.queue.insert(newSong.song, position: newSong.playType == .next ? .afterCurrentEntry : .tail)
                                    
                                    // Display a visual notification about the new song
                                    if globalScenePhase != .active {
                                        showSongAddedNotification(adderName: newSong.adderName, songTitle: newSong.song.title, artistName: newSong.song.artistName, songArtworkURL: nil, playType: newSong.playType, userName: zoneOwnerName, roomName: zoneName.components(separatedBy: " [")[0])
                                    }
                                    
                                    completionHandler(.newData)
                                } catch {
                                    print(error.localizedDescription)
                                    completionHandler(.failed)
                                }
                            }
                            
                        case .failure(let error):
                            print(error.localizedDescription)
                            completionHandler(.failed)
                        }
                    }
                    
                    CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(songFetchOperation)
                }
            }
        }
    }
    /// The standard system function called when the app is launched with system options.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
#endif

#if os(iOS)
/// The custom scene delegate class for the app.
class MultiqueueSceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    /// Whether or not a share is currently being accepted.
    @Published var isAcceptingShare = false

    /// The function called when a user opens a CloudKit share link on iOS when the app is running.
    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        if cloudKitShareMetadata.participantStatus == .pending {
            self.isAcceptingShare = true
            let acceptShareOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])
            acceptShareOperation.acceptSharesResultBlock = { (_ result: Result<Void, Error>) -> Void in
                switch result {
                case .success():
                    self.isAcceptingShare = false
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    self.isAcceptingShare = false
                }
            }
            acceptShareOperation.perShareResultBlock = { (_ metadata: CKShare.Metadata, _ metadataResult: Result<CKShare, Error>) -> Void in
                switch metadataResult {
                    
                case .success(_):
                    print("yay!")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            CKContainer(identifier: "iCloud.Multiqueue").add(acceptShareOperation)
        }
    }
    
    /// The function called when a user opens a CloudKit share link on iOS when the app is not running.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if connectionOptions.cloudKitShareMetadata != nil {
            if connectionOptions.cloudKitShareMetadata!.participantStatus == .pending {
                self.isAcceptingShare = true
                let acceptShareOperation = CKAcceptSharesOperation(shareMetadatas: [connectionOptions.cloudKitShareMetadata!])
                acceptShareOperation.acceptSharesResultBlock = { (_ result: Result<Void, Error>) -> Void in
                    switch result {
                    case .success():
                        self.isAcceptingShare = false
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        self.isAcceptingShare = false
                    }
                }
                CKContainer(identifier: "iCloud.Multiqueue").add(acceptShareOperation)
            }
        }
    }
}
#endif
