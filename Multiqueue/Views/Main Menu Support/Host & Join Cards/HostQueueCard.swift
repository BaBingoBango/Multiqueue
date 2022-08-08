//
//  HostQueueCard.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/2/22.
//

import SwiftUI

/// A card which acts as a button to start the host sequence for the user.
struct HostQueueCard: View {
    var isGray = true
    var body: some View {
        HStack {
            Image(systemName: "figure.wave.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .foregroundColor(isGray ? .gray : .blue)
            VStack(alignment: .leading) {
                Text("Host Queue")
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

struct HostQueueCard_Previews: PreviewProvider {
    static var previews: some View {
        HostQueueCard()
    }
}
