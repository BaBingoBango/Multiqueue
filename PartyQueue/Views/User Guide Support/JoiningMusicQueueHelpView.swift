//
//  JoiningMusicQueueHelpView.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/22/22.
//

import SwiftUI

struct JoiningMusicQueueHelpView: View {
    var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading) {
                    
                    Text("What is Joining?")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("\"Joining\", in the context of PartyQueue, means that your device will not be the device to actually play any music. Rather, you will be able to send Apple Music songs to a host device's queue, which will then be played from the host device's speakers or connected sound system.")
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Joining a Queue")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top)
                    
                    Text("To start the joining process, tap the \"Join a Queue\" button on the main menu. Your device will then broadcast your avaliability to join a queue to any device which has tapped on the \"Host a Queue\" button.")
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Engaging With Hosts")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top)
                    
                    Text("Since your device is broadcasting availbilty to any host within range, you might recieve multiple invitations from hosts to control their queues. On the \"Broadcasting Availability\" screen, you will see a list of host devices who have invited you. To add songs to one of their queues, simply tap that device's name in the list.")
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Adding Music")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top)
                    
                    Text("After tapping on a host device's name, you can see their current playing song, the number of connected participants, and all of the songs that have been sent to their queue. To add songs yourself, tap the \"Add Song to Queue\" button. You can add songs right from your personal library, by searching the Apple Music catalog, or by pasting a song link.")
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Managing the Queue")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top)
                    
                    Text("PartyQueue communicates with the Music app through Apple's MusicKit framework. Becuase of this, there are restrictions placed on what PartyQueue can do in the Music app on your behalf. Authorized apps cannot manage the queue in any way other than adding songs. To do more, the host will need to use their device.")
                        .fixedSize(horizontal: false, vertical: true)
                    
                }
                .multilineTextAlignment(.leading)
                
                .padding([.leading, .top])
                Spacer()
            }
        }
    }
}

struct JoiningMusicQueueHelpView_Previews: PreviewProvider {
    static var previews: some View {
        JoiningMusicQueueHelpView()
    }
}
