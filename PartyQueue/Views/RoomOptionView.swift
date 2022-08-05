//
//  RoomOptionView.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 7/29/22.
//

import SwiftUI

struct LinkedRoomOptionView: View {
    
    var room: Room
    @State var isRoomViewShowing = false
    
    var body: some View {
        ZStack {
            NavigationLink("", destination: RoomView(room: room, isRoomViewShowing: $isRoomViewShowing), isActive: $isRoomViewShowing)
            
            Button(action: {
                isRoomViewShowing = true
            }) {
                RoomOptionView(room: room)
            }
        }
    }
}

struct RoomOptionView: View {
    
    // MARK: - View Variables
    var room: Room
    
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

//struct RoomOptionView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoomOptionView(roomDetails: RoomDetails(name: "My Room Room Room Room", icon: "🎶", color: .blue, description: "Test description!"))
//    }
//}
