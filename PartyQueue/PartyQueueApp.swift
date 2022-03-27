//
//  PartyQueueApp.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/2/22.
//

import SwiftUI

@main
struct PartyQueueApp: App {
    let persistenceController = PersistenceController.shared

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
