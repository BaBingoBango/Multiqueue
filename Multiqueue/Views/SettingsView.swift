//
//  SettingsView.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/2/22.
//

import SwiftUI
import MusicKit

/// The view surfacing controls for various preferences of the app.
struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var grantedLocalNetworkPermissions = true
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    @State var subscribedToAppleMusic = false
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("PERMISSIONS & CAPABILITIES")) {
                    NavigationLink(destination: LocalNetworkSettingsView().navigationBarTitle("", displayMode: .inline)) {
                        HStack {
                            Image(systemName: grantedLocalNetworkPermissions ? "checkmark.circle.fill" : "exclamationmark.octagon.fill")
                                .imageScale(.large)
                                .foregroundColor(grantedLocalNetworkPermissions ? .green : .red)
                            Text("Local Network")
                        }
                    }
                    NavigationLink(destination: MediaSettingsView().navigationBarTitle("", displayMode: .inline)) {
                        HStack {
                            Image(systemName: MusicAuthorization.currentStatus == .authorized ? "checkmark.circle.fill" : "exclamationmark.octagon.fill")
                                .imageScale(.large)
                                .foregroundColor(MusicAuthorization.currentStatus == .authorized ? .green : .red)
                            Text("Media & Apple Music")
                        }
                    }
                    NavigationLink(destination: SubscriptionSettingsView().navigationBarTitle("", displayMode: .inline)) {
                        HStack {
                            Image(systemName: subscribedToAppleMusic ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .imageScale(.large)
                                .foregroundColor(subscribedToAppleMusic ? .green : .yellow)
                            Text("Apple Music Subscription")
                        }
                    }
                }
                
                Section(header: Text("ABOUT")) {
                    HStack {
                        Text("Version Number")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Build Number")
                        Spacer()
                        Text("4")
                            .foregroundColor(.secondary)
                    }
                }
                
            }
            
            // MARK: Navigation View Settings
            .navigationTitle(Text("Settings"))
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done").fontWeight(.bold)
            })
            
        }
        .onAppear {
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
