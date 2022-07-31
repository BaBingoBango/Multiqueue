//
//  RoomOptionView.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 7/29/22.
//

import SwiftUI

struct RoomOptionView: View {
    
    // MARK: - View Variables
    var roomDetails: RoomDetails
    
    var body: some View {
        HStack {
            Text(roomDetails.icon)
                .font(.system(size: 50))
                .foregroundColor(.primary)
                .padding(.leading)
            
            VStack(alignment: .leading) {
                Text(roomDetails.name)
                    .font(.system(size: 25))
                    .foregroundColor(.primary)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text("3 Users Invited")
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .modifier(RectangleWrapper(fixedHeight: 100, color: roomDetails.color, opacity: 0.15))
    }
}

struct RoomOptionView_Previews: PreviewProvider {
    static var previews: some View {
        RoomOptionView(roomDetails: RoomDetails(name: "My Room Room Room Room", icon: "🎶", color: .blue, description: "Test description!"))
    }
}
