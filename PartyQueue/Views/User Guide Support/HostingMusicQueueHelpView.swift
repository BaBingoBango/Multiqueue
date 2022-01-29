//
//  HostingMusicQueueHelpView.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/22/22.
//

import SwiftUI

struct HostingMusicQueueHelpView: View {
    var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading) {
                    
                    Text("What is Hosting?")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("\"Hosting\", in the context of PartyQueue, means that your device is the one that will play Apple Music songs suggested by both you and any participant devices. For example, if your device is the one connected to the speaker system at a party or the sound system of a car, your device would be the ideal choice for the host. All of the participant devices will send songs to your device, which will then be added to your personal Music app queue.")
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Hosting a Queue")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top)
                    
                    Text("To start the hosting process, tap the \"Host a Queue\" button on the main menu. Your device will then start looking for any devices which have tapped \"Join a Queue\".")
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Inviting Participants")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top)
                    
                    Text("As your device discovers devices that have tapped \"Join a Queue\", their device names will appear under \"Discovered Devices\". If you'd like to invite a device to add to your queue, tap on the device name. After a successful connection, the device name will appear under \"Connected Devices\". At this time, the device will be able to send songs to your music queue.")
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Adding Music")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top)
                    
                    Text("To view the status of your session, tap the \"View Music Queue\" button. From there, you can see the current song, the number of connected participants, and all of the songs that have been sent to your queue. To add songs yourself, you can either use the Music app directly or tap the \"Add Song to Queue\" button. You can add songs right from your personal library, by searching the Apple Music catalog, or by pasting a song link.")
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Managing the Queue")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top)
                    
                    Text("PartyQueue communicates with the Music app through Apple's MusicKit framework. Becuase of this, there are certain restrictions placed on what PartyQueue can do in the Music app on your behalf. While Apple allows authorized apps to add songs to a user's queue, they cannot manage it in any further way. In order to accomplish this management, you as the host will need to use the standard system controls.")
                        .fixedSize(horizontal: false, vertical: true)
                    
                }
                .multilineTextAlignment(.leading)
                
                .padding([.leading, .top])
                Spacer()
            }
        }
    }
}


struct HostingMusicQueueHelpView_Previews: PreviewProvider {
    static var previews: some View {
        HostingMusicQueueHelpView()
    }
}
