//
//  QueueSettings.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/23/22.
//

import SwiftUI

struct QueueSettings: View {
    
    @EnvironmentObject var multipeerServices: MultipeerServices
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            
            Section(header: Text("Song Limit"), footer: Text("The Song Limit acts like a countdown; when the number of songs added to the queue reaches the limit, the queue will be closed and all participants will be disconnected.")) {
                if multipeerServices.isSongLimit {
                    Toggle("Song Limit", isOn: $multipeerServices.isSongLimit)
                    Stepper(value: $multipeerServices.songLimit, in: 1...100) {
                        Text(multipeerServices.songLimit != 1 ? "\(multipeerServices.songLimit) Songs Remaining" : "\(multipeerServices.songLimit) Song Remaining")
                    }
                } else {
                    Toggle("Song Limit", isOn: $multipeerServices.isSongLimit)
                }
            }.onChange(of: multipeerServices.isSongLimit) { newValue in
                multipeerServices.songLimit = 10
            }
            
            Section(header: Text("Time Limit"), footer: Text("The Time Limit acts like a countdown; when the time expires, the queue will be closed and all participants will be disconnected.")) {
                if multipeerServices.isTimeLimit {
                    Toggle("Time Limit", isOn: $multipeerServices.isTimeLimit)
                    Stepper(value: $multipeerServices.timeLimit, in: 1...60) {
                        Text(multipeerServices.timeLimit != 1 ? "\(multipeerServices.timeLimit) Minutes Remaining" : "\(multipeerServices.timeLimit) Minute Remaining")
                    }
                } else {
                    Toggle("Time Limit", isOn: $multipeerServices.isTimeLimit)
                }
            }.onChange(of: multipeerServices.isTimeLimit) { newValue in
                multipeerServices.timeLimit = 0
            }
            
        }
        .navigationBarItems(trailing: Button(action: { presentationMode.wrappedValue.dismiss() }) {
            Text("Done")
                .fontWeight(.bold)
        })
    }
}

struct QueueSettings_Previews: PreviewProvider {
    static var previews: some View {
        QueueSettings().environmentObject(MultipeerServices(isHost: true))
    }
}
