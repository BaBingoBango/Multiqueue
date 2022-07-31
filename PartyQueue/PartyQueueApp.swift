//
//  PartyQueueApp.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/2/22.
//

import SwiftUI
import CloudKit

@main
struct PartyQueueApp: App {
    /// The persistence controller for Core Data.
    let persistenceController = PersistenceController.shared
    /// The custom app delegate for the app.
    @UIApplicationDelegateAdaptor var delegate: MultiqueueAppDelegate

    var body: some Scene {
        WindowGroup {
            MainMenu()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(MultipeerServices(isHost: false))
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
        }
    }
}

#if os(iOS)
/// The custom app delegate class for the app.
class MultiqueueAppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    /// Whether or not a share is currently being accepted.
    @Published var isAcceptingShare = false
    
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
