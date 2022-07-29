//
//  JoinRoomCard.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 7/29/22.
//

import SwiftUI

struct JoinRoomCard: View {
    var isGray = true
    var body: some View {
        HStack {
            Image(systemName: "envelope.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .foregroundColor(isGray ? .gray : .blue)
            VStack(alignment: .leading) {
                Text("Join a Room")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("Join another user's room to add songs to their Apple Music queue.")
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
        }
        .padding(.all)
        .modifier(RectangleWrapper(fixedHeight: 150, color: isGray ? .gray : .blue))
    }
}

struct JoinRoomCard_Previews: PreviewProvider {
    static var previews: some View {
        JoinRoomCard()
    }
}
