//
//  PermissionsAlertCard.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/2/22.
//

import SwiftUI

/// A card alerting the user that there are issues realting to the app's permissions.
struct NetworkPermissionsAlertCard: View {
    var body: some View {
        VStack {
            Image(systemName: "wifi.exclamationmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .foregroundColor(.red)
                .padding(.top)
            Text("No Local Network Access")
                .font(.title3)
                .fontWeight(.bold)
            Text("Since PartyQueue communicates wirelessly with nearby devices, you will not be able to use PartyQueue until you grant Local Network access in Settings.")
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding([.bottom, .horizontal])
                .padding(.top, 1)
        }
        .modifier(RectangleWrapper(fixedHeight: 215, color: .red))
    }
}

struct NetworkPermissionsAlertCard_Previews: PreviewProvider {
    static var previews: some View {
        NetworkPermissionsAlertCard()
    }
}
