//
//  JoiningView.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/3/22.
//

import SwiftUI
import MultipeerConnectivity
import MusicKit

struct JoiningView: View {

//    @ObservedObject var multipeerServices: MultipeerServices = MultipeerServices(isHost: false)
    @ObservedObject var multipeerServices: MultipeerServices = MultipeerServices(isHost: false)
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ScrollView {
            VStack {
                
                Image(systemName: "dot.radiowaves.left.and.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                    .foregroundColor(.accentColor)
                    .padding(.top)
                
                HStack {
                    Text("Broadcasting Availability")
                        .font(.title)
                        .fontWeight(.bold)
                    ProgressView()
                        .padding(.leading, 1)
                }
                
                if multipeerServices.connectedDevices.isEmpty {
                    HStack {
                        Text("To access someone else's music queue, have them open Multiqueue and tap Host Queue. They'll see your device name and can invite you to their session.")
                        Spacer()
                    }
                        .padding(.all)
                        .modifier(RectangleWrapper())
                        .padding(.horizontal)
                } else {
                    HStack {
                        Text("Connected Devices")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding([.top, .leading])
                    ForEach(multipeerServices.connectedDevices, id: \.self) { peer in
                        
                        NavigationLink(destination: QueueView().environmentObject(multipeerServices).navigationBarTitle(Text("Music Queue"), displayMode: .large)) {
                            JoiningViewConnectedDeviceRow(text: peer.displayName)
                        }
                        
                    }
                    .padding(.horizontal)
                }
                
                if !multipeerServices.connectedDevices.isEmpty {
                    Button(action: {
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
            multipeerServices.isHost = false
            multipeerServices.isReceivingData = true
        }
        .onDisappear {
            
            // MARK: - View Vanish Code
//            multipeerServices.isReceivingData = false
//            multipeerServices.session.disconnect()
            
        }
    }
}

struct JoiningView_Previews: PreviewProvider {
    static var previews: some View {
        JoiningView(multipeerServices: MultipeerServices(isHost: false))
    }
}
