//
//  RoomInfoView.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 8/3/22.
//

import SwiftUI

/// A view prividing information about a room and optionally surfacing controls for its editing.
struct RoomInfoView: View {
    
    // MARK: - View Variables
    @Environment(\.presentationMode) var presentationMode
    /// The information for the room this view describes and edits.
    @Binding var roomDetails: RoomDetails
    var isHost: Bool
    
    @State var isShowingIconPicker = false
    
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
                                    .foregroundColor(roomDetails.color)
                                    .opacity(0.3)
                                
                                Text(roomDetails.icon)
                                    .font(.system(size: geometry.size.height > geometry.size.width ? geometry.size.width * 0.6: geometry.size.height * 0.6))
                            }
                        }
                        .aspectRatio(contentMode: .fit)
                        
                        Circle()
                            .aspectRatio(contentMode: .fit)
                            .hidden()
                    }
                    
                    Text(roomDetails.name)
                        .fontWeight(.bold)
                        .font(.title)
                }
                .listRowBackground(Color(UIColor.systemGroupedBackground))
                
                Section(header: Text("Song Limit")) {
                    if isHost {
                        Toggle("Song Limit", isOn: .constant(true))
                    } else {
                        HStack {
                            Text("Song Limit")
                            Spacer()
                            Text("Enabled")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Songs Remaining")
                        Spacer()
                        Text("\(23) Songs")
                            .foregroundColor(.secondary)
                    }
                    
                    if isHost {
                        Button(action: {
                            
                        }) {
                            Text("Set Song Limit...")
                        }
                    }
                    
                    if isHost {
                        Picker(selection: .constant(LimitExpirationAction.nothing), label: Text("Expiration Action")) {
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
                    if isHost {
                        Toggle("Time Limit", isOn: .constant(true))
                    } else {
                        HStack {
                            Text("Time Limit")
                            Spacer()
                            Text("Enabled")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Time Remaining")
                        Spacer()
                        Text("1:36:23")
                            .foregroundColor(.secondary)
                    }
                    
                    if isHost {
                        Button(action: {
                            
                        }) {
                            Text("Set Time Limit...")
                        }
                    }
                    
                    if isHost {
                        Picker(selection: .constant(LimitExpirationAction.nothing), label: Text("Expiration Action")) {
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
                                
                                Text(roomDetails.icon)
                                
                                Image(systemName: "chevron.right")
                                    .font(Font.body.weight(.semibold))
                                    .foregroundColor(.secondary)
                                    .imageScale(.small)
                                    .opacity(0.25)
                            }
                        }
                        .sheet(isPresented: $isShowingIconPicker) {
                            RoomEmojiPickerView(roomColor: roomDetails.color, enteredIcon: $roomDetails.icon)
                        }
                        
                        ColorPicker("Room Color", selection: $roomDetails.color)
                    }
                }
                
                Section(header: Text("Description")) {
                    TextEditor(text: $roomDetails.description)
                        .frame(height: 100)
                        .disabled(!isHost)
                }
            }
            
            // MARK: - Navigation View Settings
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(action: { self.presentationMode.wrappedValue.dismiss() }) { Text("Done").fontWeight(.bold) })
        }
    }
}

struct RoomInfoView_Previews: PreviewProvider {
    static var previews: some View {
        RoomInfoView(roomDetails: .constant(RoomDetails(name: "Preview Room", icon: "😩", color: .blue, description: "This is a preview room! Cool!")), isHost: true)
    }
}
