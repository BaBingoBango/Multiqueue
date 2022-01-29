//
//  SubscriptionSettingsView.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/21/22.
//

import SwiftUI
import MusicKit

struct SubscriptionSettingsView: View {
    
    @State var subscribedToAppleMusic = false
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack {
                
                HStack {
                    Image(systemName: "music.quarternote.3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.secondary)
                        .hidden()
                    Image(systemName: "music.quarternote.3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.accentColor)
                    Image(systemName: "music.quarternote.3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.secondary)
                        .hidden()
                }
                .padding([.top, .leading, .trailing])
                
                Text("Apple Music Subscription")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                if subscribedToAppleMusic {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                            .foregroundColor(.green)
                        Text("You're subscribed to Apple Music!")
                        Spacer()
                    }
                    .padding([.top, .leading, .bottom])
                    .modifier(RectangleWrapper(color: .green))
                    .padding(.horizontal)
                } else {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                            .foregroundColor(.yellow)
                        Text("You're either not subscribed to Apple Music or have restricted Media & Apple Music access in Settings.")
                        Spacer()
                    }
                    .padding([.top, .leading, .bottom])
                    .modifier(RectangleWrapper(color: .yellow))
                    .padding(.horizontal)
                }
                
                HStack {
                    Text("About Apple Music Usage")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding([.top, .leading])
                
                HStack {
                    Text("")
                        .multilineTextAlignment(.leading)
                        .offset(y: 5)
                    Spacer()
                }
                .padding(.leading)
                
            }
        }
        .onAppear {
            getAppleMusicStatusProxy()
        }
        .onReceive(timer) { time in
            getAppleMusicStatusProxy()
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

struct SubscriptionSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionSettingsView()
    }
}
