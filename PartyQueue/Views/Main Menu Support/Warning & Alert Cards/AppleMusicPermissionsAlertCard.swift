//
//  AppleMusicPermissionsAlertCard.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/21/22.
//

import SwiftUI

struct AppleMusicPermissionsAlertCard: View {
    var body: some View {
        VStack {
            Image(systemName: "speaker.badge.exclamationmark.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .foregroundColor(.red)
                .padding(.top)
                .padding(.top)
            Text("No Media & Apple Music Access")
                .font(.title3)
                .fontWeight(.bold)
            Text("Since PartyQueue needs to look up and play songs from Apple Music, you will not be able to use it until you grant Media & Apple Music access in Settings.")
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding([.bottom, .horizontal])
                .padding(.top, 1)
                .padding(.bottom)
        }
        .modifier(RectangleWrapper(fixedHeight: 215, color: .red))
    }
}

struct AppleMusicPermissionsAlertCard_Previews: PreviewProvider {
    static var previews: some View {
        AppleMusicPermissionsAlertCard()
    }
}
