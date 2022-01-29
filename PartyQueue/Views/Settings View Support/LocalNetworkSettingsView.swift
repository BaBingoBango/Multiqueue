//
//  LocalNetworkSettingsView.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/21/22.
//

import SwiftUI

struct LocalNetworkSettingsView: View {
    
    @State var grantedLocalNetworkPermissions = true
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack {
                
                HStack {
                    Image(systemName: "network")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.secondary)
                        .hidden()
                    Image(systemName: "network")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.accentColor)
                    Image(systemName: "network")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.secondary)
                        .hidden()
                }
                .padding([.top, .leading, .trailing])
                
                Text("Local Network Access")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                if grantedLocalNetworkPermissions {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                            .foregroundColor(.green)
                        Text("You've granted PartyQueue Local Network access. To revoke access, visit Settings > Privacy > Local Network.")
                        Spacer()
                    }
                    .padding([.top, .leading, .bottom])
                    .modifier(RectangleWrapper(color: .green))
                    .padding(.horizontal)
                } else {
                    HStack {
                        Image(systemName: "exclamationmark.octagon.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                            .foregroundColor(.red)
                        Text("You haven't given PartyQueue Local Network access. To grant access, visit Settings > Privacy > Local Network.")
                        Spacer()
                    }
                    .padding([.top, .leading, .bottom])
                    .modifier(RectangleWrapper(color: .red))
                    .padding(.horizontal)
                }
                
                HStack {
                    Text("About Local Network Usage")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding([.top, .leading])
                
                HStack {
                    Text("PartyQueue allows multiple devices to contribute to a single music queue by sending data between devices. When one device makes a change to the music queue, a copy of that queue is trasmitted to all participant devices. In order to facilitate this transfer without needing to connect to the Internet, PartyQueue uses Apple's Multipeer Connectivity framework.\n\nIn this case, PartyQueue encodes Apple Music songs, the device name of the participant (e.g. \"My Cool iPhone\"), and the current time into JSON, which is then sent to other local devices.\n\nFor privacy reasons, Apple requires users explicity approve data transmissions of this type. You can grant or revoke this approval at any time in the Settings app.")
                        .multilineTextAlignment(.leading)
                        .offset(y: 5)
                    Spacer()
                }
                .padding(.leading)
                
            }
        }
        .onAppear {
            LocalNetworkAuthorization().requestAuthorization(completion: { authorization in
                grantedLocalNetworkPermissions = authorization
            })
        }
        .onReceive(timer) { time in
            LocalNetworkAuthorization().requestAuthorization(completion: { authorization in
                grantedLocalNetworkPermissions = authorization
            })
        }
    }
}

struct LocalNetworkSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        LocalNetworkSettingsView()
    }
}
