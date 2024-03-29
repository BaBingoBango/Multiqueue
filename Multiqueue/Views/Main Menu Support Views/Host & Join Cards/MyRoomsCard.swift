//
//  MyRoomsCard.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 7/24/22.
//

import SwiftUI

/// The main menu card giving users access to the My Rooms view.
struct MyRoomsCard: View {
    var isGray = true
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .foregroundColor(isGray ? .gray : .blue)
            VStack(alignment: .leading) {
                Text("Host a Room")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("Invite others to use your Apple Music subscription to add songs to your music queue.")
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
        }
        .padding(.all)
        .modifier(RectangleWrapper(color: isGray ? .gray : .blue))
    }
}

struct MyRoomsCard_Previews: PreviewProvider {
    static var previews: some View {
        MyRoomsCard()
    }
}
