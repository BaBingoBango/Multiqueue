//
//  RoomInfoView.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 8/3/22.
//

import SwiftUI
import CloudKit

/// A view prividing information about a room and optionally surfacing controls for its editing.
struct RoomInfoView: View {
    
    // MARK: - View Variables
    @Environment(\.presentationMode) var presentationMode
    /// The information for the room this view describes and edits.
    @Binding var room: Room
    var isHost: Bool
    
    @State var isShowingIconPicker = false
    @State var isShowingSongLimitEditor = false
    @State var isShowingTimeLimitEditor = false
    @State var isShowingDeletionConfirmation = false
    
    @Binding var isRoomViewShowing: Bool
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            Form {
                VStack {
                    HStack {
                        Circle()
                            .aspectRatio(contentMode: .fit)
                            .hidden()
                        
                        GeometryReader { geometry in
                            ZStack {
                                Circle()
                                    .foregroundColor(room.details.color)
                                    .opacity(0.3)
                                
                                Text(room.details.icon)
                                    .font(.system(size: geometry.size.height > geometry.size.width ? geometry.size.width * 0.6: geometry.size.height * 0.6))
                            }
                        }
                        .aspectRatio(contentMode: .fit)
                        
                        Circle()
                            .aspectRatio(contentMode: .fit)
                            .hidden()
                    }
                    
                    Text(room.details.name)
                        .fontWeight(.bold)
                        .font(.title)
                }
                .listRowBackground(Color(UIColor.systemGroupedBackground))
                
                Section(footer: Text("An inactive room will not accept new songs, but will still be visible to participants.")) {
                    Toggle("Enable Room", isOn: $room.isActive)
                }
                
                Section(header: Text("Song Limit")) {
                    let isSongLimitOn = Binding(
                        get: { return room.songLimit > 0 },
                        set: { newValue, _ in
                            if room.songLimit > 0 {
                                room.songLimit = 0
                            } else {
                                room.songLimit = 10
                            }
                        }
                    )
                    
                    if isHost {
                        Toggle("Song Limit", isOn: isSongLimitOn)
                    } else {
                        HStack {
                            Text("Song Limit")
                            Spacer()
                            Text("Enabled")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if isSongLimitOn.wrappedValue {
                        HStack {
                            Text("Songs Remaining")
                            Spacer()
                            Text("\(room.songLimit) Songs")
                                .foregroundColor(.secondary)
                        }
                        
                        if isHost {
                            Button(action: {
                                isShowingSongLimitEditor = true
                            }) {
                                Text("Set Song Limit...")
                            }
                            .sheet(isPresented: $isShowingSongLimitEditor) {
                                LimitSetterView(limitName: "Song", limit: $room.songLimit)
                            }
                        }
                    }
                    
                    if isHost {
                        Picker(selection: $room.songLimitAction, label: Text("Expiration Action")) {
                            Text("No Action").tag(LimitExpirationAction.nothing)
                            Text("Deactivate Room").tag(LimitExpirationAction.deactivateRoom)
                            Text("Remove Participants").tag(LimitExpirationAction.removeParticipants)
                            Text("Delete Room").tag(LimitExpirationAction.deleteRoom)
                        }
                    } else {
                        HStack {
                            Text("Expiration Action")
                            Spacer()
                            Text("No Action")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Time Limit")) {
                    let isTimeLimitOn = Binding(
                        get: { return room.timeLimit > 0 },
                        set: { newValue, _ in
                            if room.timeLimit > 0 {
                                room.timeLimit = 0
                            } else {
                                room.timeLimit = 600
                            }
                        }
                    )
                    
                    if isHost {
                        Toggle("Time Limit", isOn: isTimeLimitOn)
                    } else {
                        HStack {
                            Text("Time Limit")
                            Spacer()
                            Text("Enabled")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if isTimeLimitOn.wrappedValue {
                        HStack {
                            Text("Time Remaining")
                            Spacer()
                            Text(verbatim: {
                                let timeLeft = secondsToHoursMinutesSeconds(room.timeLimit)
                                return "\(timeLeft.0 < 10 ? "0" : "")\(timeLeft.0):\(timeLeft.1 < 10 ? "0" : "")\(timeLeft.1):\(timeLeft.2 < 10 ? "0" : "")\(timeLeft.2)"
                            }())
                                .foregroundColor(.secondary)
                        }
                        
                        if isHost {
                            Button(action: {
                                isShowingTimeLimitEditor = true
                            }) {
                                Text("Set Time Limit...")
                            }
                            .sheet(isPresented: $isShowingTimeLimitEditor) {
                                LimitSetterView(limitName: "Time", limit: $room.timeLimit)
                            }
                        }
                    }
                    
                    if isHost {
                        Picker(selection: $room.timeLimitAction, label: Text("Expiration Action")) {
                            Text("No Action").tag(LimitExpirationAction.nothing)
                            Text("Deactivate Room").tag(LimitExpirationAction.deactivateRoom)
                            Text("Remove Participants").tag(LimitExpirationAction.removeParticipants)
                            Text("Delete Room").tag(LimitExpirationAction.deleteRoom)
                        }
                    } else {
                        HStack {
                            Text("Expiration Action")
                            Spacer()
                            Text("No Action")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if isHost {
                    Section(header: Text("Customization")) {
                        Button(action: {
                            isShowingIconPicker = true
                        }) {
                            HStack {
                                Text("Room Icon")
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text(room.details.icon)
                                
                                Image(systemName: "chevron.right")
                                    .font(Font.body.weight(.semibold))
                                    .foregroundColor(.secondary)
                                    .imageScale(.small)
                                    .opacity(0.25)
                            }
                        }
                        .sheet(isPresented: $isShowingIconPicker) {
                            RoomEmojiPickerView(roomColor: room.details.color, enteredIcon: $room.details.icon)
                        }
                        
                        ColorPicker("Room Color", selection: $room.details.color)
                    }
                }
                
                Section(header: Text("Description")) {
                    TextEditor(text: $room.details.description)
                        .frame(height: 100)
                        .disabled(!isHost)
                }
                
                if isHost {
                    Button(action: {
                        isShowingDeletionConfirmation = true
                    }) {
                        Text("Delete Room")
                    }
                    .confirmationDialog("Are you sure you want to delete this room? All participants will be removed and all data will be deleted.", isPresented: $isShowingDeletionConfirmation, titleVisibility: .visible) {
                        Button("Delete Room", role: .destructive) {
                            let roomDeleteOperation = CKModifyRecordZonesOperation(recordZoneIDsToDelete: [room.zone.zoneID])
                            
                            roomDeleteOperation.perRecordZoneDeleteBlock = { (_ recordZoneID: CKRecordZone.ID, _ deleteResult: Result<Void, Error>) -> Void in
                                switch deleteResult {
                                case .success():
                                    presentationMode.wrappedValue.dismiss()
                                    isRoomViewShowing = false
                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                            }
                            
                            CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(roomDeleteOperation)
                        }
                    }
                }
            }
            
            // MARK: - Navigation View Settings
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(action: { self.presentationMode.wrappedValue.dismiss() }) { Text("Done").fontWeight(.bold) })
        }
    }
}

//struct RoomInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoomInfoView(roomDetails: .constant(RoomDetails(name: "Preview Room", icon: "😩", color: .blue, description: "This is a preview room! Cool!")), isHost: true)
//    }
//}
