//
//  MainMenu.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/2/22.
//

import SwiftUI
import MusicKit
import Network

/// The landing view for the app. It contains navigation to all the major features, including hosting, joining, settings, and help.
struct MainMenu: View {
    
    /// The custom scene delegate object for the app.
    @EnvironmentObject var sceneDelegate: MultiqueueSceneDelegate
    
    @EnvironmentObject var multipeerServices: MultipeerServices
    
    @State var subscribedToAppleMusic = false
    @State var grantedLocalNetworkPermissions = true
    @State var areNotificationsOn = false
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack {
                    
                    // MARK: - 1: Alert & Warning Cards
                    
                    if MusicAuthorization.currentStatus != .authorized {
                        Button(action: {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, completionHandler: { _ in })
                        }) {
                            AppleMusicPermissionsAlertCard()
                                .padding([.top, .leading, .trailing])
                        }
                    }
                    
                    if !subscribedToAppleMusic && MusicAuthorization.currentStatus == .authorized {
                        AppleMusicWarningCard()
                            .padding([.top, .leading, .trailing])
                    }
                    
                    // MARK: - 2: Room Management Cards
                    NavigationLink(destination: MyRoomsView()) {
                        MyRoomsCard(isGray: !grantedLocalNetworkPermissions || MusicAuthorization.currentStatus != .authorized)
                            .padding([.top, .leading, .trailing])
                    }
                    .disabled(!subscribedToAppleMusic || MusicAuthorization.currentStatus != .authorized)
                    
                    NavigationLink(destination: JoinRoomView()) {
                        JoinRoomCard(isGray: !grantedLocalNetworkPermissions || MusicAuthorization.currentStatus != .authorized)
                            .padding([.top, .leading, .trailing])
                    }
                    .disabled(MusicAuthorization.currentStatus != .authorized)
                    
                    // MARK: - 3: Notification Card
                    Button(action: {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, completionHandler: { _ in })
                    }) {
                        NotificationStatusCard(areNotificationsOn: areNotificationsOn)
                            .padding([.top, .leading, .trailing])
                    }
                    
                    // MARK: - 4: OK/Status Cards
                    
                    if subscribedToAppleMusic {
                        AppleMusicOKCard()
                            .padding([.top, .leading, .trailing])
                    }
                    
                    if MusicAuthorization.currentStatus == .authorized && grantedLocalNetworkPermissions {
                        Button(action: {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, completionHandler: { _ in })
                        }) {
                            PermissionsOKCard()
                                .padding([.top, .leading, .trailing])
                        }
                    }
                    
                }
            }
            
            // MARK: - Navigation View Settings
            .navigationTitle(Text("Multiqueue"))
            .navigationBarItems(trailing: HStack { MainMenuNavigationButtonsR().padding(.leading, 10) })
            
        }
        .onAppear {
            // MARK: - View Launch Code
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            @Sendable func requestMusicAuthorizationAsync() async {
                _ = await MusicKit.MusicAuthorization.request()
            }
            func requestMusicAuthorization() {
                Task {
                    await requestMusicAuthorizationAsync()
                }
            }
            requestMusicAuthorization()
            getAppleMusicStatusProxy()
        }
        .onReceive(timer) { time in
            getAppleMusicStatusProxy()
            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings { settings in
                areNotificationsOn = settings.authorizationStatus == .authorized
            }
        }
        .alert("Accepting Room Invitation...", isPresented: $sceneDelegate.isAcceptingShare) {
            Button("Cancel", role: .cancel) { }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func getAppleMusicStatus() async {
        do {
            try await subscribedToAppleMusic = MusicSubscription.current.canPlayCatalogContent
        } catch {
            print(error.localizedDescription)
        }
    }

    func getAppleMusicStatusProxy() {
        Task {
            await getAppleMusicStatus()
        }
    }
    
}

struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu().environmentObject(MultipeerServices(isHost: true))
    }
}
