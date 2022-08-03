//
//  MainMenu.swift
//  PartyQueue
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
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack {
                    
                    // MARK: - 1: Alert & Warning Cards
                    
                    if !grantedLocalNetworkPermissions {
                        NetworkPermissionsAlertCard()
                            .padding([.top, .leading, .trailing])
                    }
                    
                    if MusicAuthorization.currentStatus != .authorized {
                        AppleMusicPermissionsAlertCard()
                            .padding([.top, .leading, .trailing])
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
                    .disabled(!grantedLocalNetworkPermissions || MusicAuthorization.currentStatus != .authorized)
                    
                    NavigationLink(destination: JoinRoomView()) {
                        JoinRoomCard(isGray: !grantedLocalNetworkPermissions || MusicAuthorization.currentStatus != .authorized)
                            .padding([.top, .leading, .trailing])
                    }
                    
//                    NavigationLink(destination: HostingView().environmentObject(multipeerServices).navigationBarTitle(Text("Host Queue"), displayMode: .inline).environmentObject(MultipeerServices(isHost: true))) {
//                        HostQueueCard(isGray: !grantedLocalNetworkPermissions || MusicAuthorization.currentStatus != .authorized)
//                            .padding([.top, .leading, .trailing])
//                    }
//                    .disabled(!grantedLocalNetworkPermissions || MusicAuthorization.currentStatus != .authorized)
//
//                    NavigationLink(destination: JoiningView().environmentObject(MultipeerServices(isHost: false)).navigationBarTitle(Text("Join Queue"), displayMode: .inline)) {
//                        JoinQueueCard(isGray: !grantedLocalNetworkPermissions || MusicAuthorization.currentStatus != .authorized)
//                            .padding([.top, .leading, .trailing])
//                    }
//                    .disabled(!grantedLocalNetworkPermissions || MusicAuthorization.currentStatus != .authorized)
                    
                    // MARK: - 3: OK/Status Cards
                    
                    if MusicAuthorization.currentStatus == .authorized && grantedLocalNetworkPermissions {
                        PermissionsOKCard()
                            .padding([.top, .leading, .trailing])
                    }
                    
                    if subscribedToAppleMusic {
                        AppleMusicOKCard()
                            .padding([.top, .leading, .trailing])
                    }
                    
                }
            }
            
            // MARK: - Navigation View Settings
            .navigationTitle(Text("Multiqueue"))
            .navigationBarItems(trailing: HStack { MainMenuNavigationButtonsL(); MainMenuNavigationButtonsR().padding(.leading, 10) })
            
        }.onAppear {
            // MARK: - View Launch Code
//            multipeerServices.stopBrowsing()
//            multipeerServices.isReceivingData = false
//            multipeerServices.session.disconnect()
            
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
            LocalNetworkAuthorization().requestAuthorization(completion: { authorization in
                grantedLocalNetworkPermissions = authorization
            })
        }
        .onReceive(timer) { time in
            getAppleMusicStatusProxy()
            LocalNetworkAuthorization().requestAuthorization(completion: { authorization in
                grantedLocalNetworkPermissions = authorization
            })
        }
        .alert("Accepting Room Invitation...", isPresented: $sceneDelegate.isAcceptingShare) {
            Button("Dismiss", role: .cancel) { }
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
