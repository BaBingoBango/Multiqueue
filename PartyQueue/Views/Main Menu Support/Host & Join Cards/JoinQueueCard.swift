//
//  JoinQueueCard.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/2/22.
//

import SwiftUI

/// A card which acts as a button to start the join sequence for the user.
struct JoinQueueCard: View {
    var isGray = true
    var body: some View {
        HStack {
            Image(systemName: "person.2.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .foregroundColor(isGray ? .gray : .blue)
            VStack(alignment: .leading) {
                Text("Join Queue")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("Add songs to a friend's music queue using their Apple Music subscription.")
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
        }
        .padding(.all)
        .modifier(RectangleWrapper(fixedHeight: 150, color: isGray ? .gray : .blue))
    }
}

struct JoinQueueCard_Previews: PreviewProvider {
    static var previews: some View {
        JoinQueueCard()
    }
}
