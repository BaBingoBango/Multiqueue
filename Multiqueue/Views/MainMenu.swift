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
    
    /// The horizontal size class of the current app environment.
    ///
    /// It is only relevant in iOS and iPadOS, since macOS and tvOS feature a consistent layout experience.
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    /// The currently selected sidebar tab.
    @State var selection: Int? = 1
    
    /// The custom scene delegate object for the app.
    @EnvironmentObject var sceneDelegate: MultiqueueSceneDelegate
    
    @State var subscribedToAppleMusic = false
    @State var grantedLocalNetworkPermissions = true
    @State var areNotificationsOn = false
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            if horizontalSizeClass == .compact {
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
                                MyRoomsCard(isGray: !subscribedToAppleMusic || MusicAuthorization.currentStatus != .authorized)
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
                        .padding(.bottom)
                    }
                    
                    // MARK: - Navigation View Settings
                    .navigationTitle(Text("Multiqueue"))
                    .navigationBarItems(trailing: HStack { MainMenuNavigationButtonsR().padding(.leading, 10) })
                    
                }
                .navigationViewStyle(StackNavigationViewStyle())
            } else {
                NavigationView {
                    List(selection: $selection) {
                        NavigationLink(destination: { () -> AnyView in
                            if MusicAuthorization.currentStatus != .authorized {
                                return AnyView(ScrollView {
                                    VStack {
                                        AppleMusicPermissionsAlertCard()
                                            .padding(.horizontal)
                                            .navigationTitle(Text("My Rooms"))
                                    }
                                })
                            } else {
                                if subscribedToAppleMusic {
                                    return AnyView(MyRoomsView().navigationTitle(Text("My Rooms")))
                                } else {
                                    return AnyView(ScrollView {
                                        VStack {
                                            AppleMusicWarningCard()
                                                .padding(.horizontal)
                                                .navigationTitle(Text("My Rooms"))
                                        }
                                    })
                                }
                            }
                        }(), tag: 1, selection: $selection) {
                            Label("My Rooms", systemImage: "music.note.house.fill")
                        }
                        
                        NavigationLink(destination: { () -> AnyView in
                            if MusicAuthorization.currentStatus != .authorized {
                                return AnyView(ScrollView {
                                    VStack {
                                        AppleMusicPermissionsAlertCard()
                                            .padding(.horizontal)
                                            .navigationTitle(Text("Join Room"))
                                    }
                                })
                            } else {
                                return AnyView(JoinRoomView().navigationTitle(Text("Join Room")))
                            }
                        }(), tag: 2, selection: $selection) {
                            Label("Join Room", systemImage: "envelope.fill")
                        }
                        
                        NavigationLink(destination: SettingsView(), tag: 3, selection: $selection) {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                    .listStyle(SidebarListStyle())
                    .navigationTitle("Multiqueue")
                }
            }
        }
        .onAppear {
            // MARK: - View Launch Code
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
                if let error = error {
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
        MainMenu()
    }
}
