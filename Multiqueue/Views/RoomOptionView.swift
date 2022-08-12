//
//  RoomOptionView.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 7/29/22.
//

import SwiftUI
import CloudKit

/// An option view for a room, linked to a room view via a `NavigationLink`.
struct LinkedRoomOptionView: View {
    
    // MARK: - View Variables
    /// The room this view describes.
    @Binding var room: Room
    /// Whether or not a room view is being presented.
    @State var isRoomViewShowing = false
    /// Whether or not the current user is this room's host.
    var isHost: Bool
    
    // MARK: - View Body
    var body: some View {
        ZStack {
            NavigationLink("", destination: isHost ? AnyView(RoomView(room: room, isRoomViewShowing: $isRoomViewShowing)) : AnyView(JoinedRoomView(room: room, isRoomViewShowing: $isRoomViewShowing)), isActive: $isRoomViewShowing)
            
            Button(action: {
                isRoomViewShowing = true
            }) {
                RoomOptionView(room: room)
            }
        }
        .onChange(of: isRoomViewShowing) { newValue in
            // Update the HostOnScreen field of the room
            if newValue {
                room.hostOnScreen = true
                room.details.record["HostOnScreen"] = 1
            } else {
                room.hostOnScreen = false
                room.details.record["HostOnScreen"] = 0
                
                let roomDetailsUploadOperation = CKModifyRecordsOperation(recordsToSave: [room.details.record])
                CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(roomDetailsUploadOperation)
            }
        }
    }
}

/// A list option view for a room.
struct RoomOptionView: View {
    
    // MARK: - View Variables
    /// The room this view describes.
    var room: Room
    
    // MARK: - View Body
    var body: some View {
        HStack {
            Text(room.details.icon)
                .font(.system(size: 50))
                .foregroundColor(.primary)
                .padding(.leading)
            
            VStack(alignment: .leading) {
                Text(room.details.name)
                    .font(.system(size: 25))
                    .foregroundColor(.primary)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text("\(room.share.participants.count) Participant\(room.share.participants.count != 1 ? "s" : "")")
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .modifier(RectangleWrapper(fixedHeight: 100, color: room.details.color, opacity: 0.15))
    }
}
