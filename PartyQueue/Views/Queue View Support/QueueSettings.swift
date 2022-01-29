//
//  QueueSettings.swift
//  PartyQueue
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
                    HStack {
                        Picker("No. of Songs", selection: $multipeerServices.songLimit) {
                            ForEach(0...50, id: \.self) {
                                Text("\($0)")
                            }
                        }.pickerStyle(MenuPickerStyle())
                        Spacer()
                        Toggle("", isOn: $multipeerServices.isSongLimit)
                    }
                } else {
                    Toggle("Song Limit", isOn: $multipeerServices.isSongLimit)
                }
            }.onChange(of: multipeerServices.isSongLimit) { newValue in
                multipeerServices.songLimit = 10
            }
            
            Section(header: Text("Time Limit"), footer: Text("The Time Limit acts like a countdown; when the time expires, the queue will be closed and all participants will be disconnected.")) {
                if multipeerServices.isTimeLimit {
                    HStack {
                        Picker("No. of Seconds", selection: $multipeerServices.timeLimit) {
                            ForEach(0...120, id: \.self) {
                                Text("\($0)")
                            }
                        }.pickerStyle(MenuPickerStyle())
                        Spacer()
                        Toggle("", isOn: $multipeerServices.isTimeLimit)
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
