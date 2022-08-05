//
//  HostingView.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/3/22.
//

import SwiftUI
import MultipeerConnectivity
import MusicKit

struct HostingView: View {
    
    @ObservedObject var multipeerServices: MultipeerServices = MultipeerServices(isHost: true)
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100)
                        .foregroundColor(.accentColor)
                        .padding(.top)
                    
                    HStack {
                        Text("Looking For Participants")
                            .font(.title)
                            .fontWeight(.bold)
                        ProgressView()
                            .padding(.leading, 1)
                    }
                    
                    if !$multipeerServices.discoveredDevices.isEmpty {
                        HStack {
                            Text("Nearby Devices")
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding([.top, .leading])
                    } else if $multipeerServices.connectedDevices.isEmpty {
                        HStack {
                            Text("To allow others access to your music queue, have them open Multiqueue and tap Join Queue. You'll see their device appear here.")
                            Spacer()
                        }
                            .padding(.all)
                            .modifier(RectangleWrapper())
                            .padding(.horizontal)
                    }
                    
                    ForEach(multipeerServices.discoveredDevices, id: \.self) { peer in
                        
                        Button(action: {
                            multipeerServices.invitePeer(peer)
                        }) {
                            HostingViewConnectedDeviceRow(text: peer.displayName)
                        }
                        
                    }
                    .padding(.horizontal)
                    
                    if !$multipeerServices.connectedDevices.isEmpty {
                        HStack {
                            Text("Connected Devices")
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding([.top, .leading])
                    }
                    
                    ForEach(multipeerServices.connectedDevices, id: \.self) { peer in
                        
                        HostingViewConnectedDeviceRow(text: peer.displayName, showInvite: false)
                        
                    }
                    .padding(.horizontal)
                    
                    if !$multipeerServices.connectedDevices.isEmpty {
                        Button(action: {
                            do {
                                try multipeerServices.session.send("DISCONNECT SIGNAL".data(using: .utf8)!, toPeers: multipeerServices.session.connectedPeers, with: .reliable)
                            } catch {
                                print(error.localizedDescription)
                            }
                            multipeerServices.stopBrowsing()
                            multipeerServices.isReceivingData = false
                            multipeerServices.session.disconnect()
                            multipeerServices.connectedDevices = []
                            multipeerServices.discoveredDevices = []
                            multipeerServices.queueState = QueueState(currentSong: SongState(title: SystemMusicPlayer.shared.queue.currentEntry?.title ?? "No Current Song", artist: SystemMusicPlayer.shared.queue.currentEntry?.description.components(separatedBy: "artistName: \"")[1].components(separatedBy: "\"))")[0] ?? ""), addedToQueue: [])
                            self.presentationMode.wrappedValue.dismiss()
                            multipeerServices.isSongLimit = false
                            multipeerServices.isTimeLimit = false
                        }) {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.accentColor)
                                    .cornerRadius(15)
                                    .frame(height: 50)
                                Text("Disconnect Current Sessions")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                }
            }.onAppear {
                
                // MARK: - View Launch Code
                multipeerServices.connectedDevices = []
                multipeerServices.discoveredDevices = []
                multipeerServices.isHost = true
                multipeerServices.startBrowsing()
                print("Browsing has started!")
                
            }
            .onDisappear {
                
                // MARK: - View Vanish Code
//                multipeerServices.stopBrowsing()
//                print("Browsing has ended!")
//                multipeerServices.session.disconnect()
                
            }
            
            NavigationLink(destination: QueueView().environmentObject(multipeerServices).navigationBarTitle(Text("Music Queue"), displayMode: .large)) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.accentColor)
                        .cornerRadius(15)
                        .frame(height: 55)
                    Text("View Music Queue")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .padding([.top, .leading, .trailing])
            
        }
    }
}

struct HostingView_Previews: PreviewProvider {
    static var previews: some View {
        HostingView()
    }
}
