//
//  AppleMusicWarningCard.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/21/22.
//

import SwiftUI

/// A main menu card warning users that they are not subscribed to Apple Music.
struct AppleMusicWarningCard: View {
    var body: some View {
        VStack {
            Image(systemName: "speaker.badge.exclamationmark.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .foregroundColor(.yellow)
                .padding(.top)
            Text("No Apple Music Subscription")
                .font(.title3)
                .fontWeight(.bold)
            Text("Without an Apple Music subscription tied to your Apple ID, you will not be able to host rooms.")
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding([.bottom, .horizontal])
                .padding(.top, 1)
        }
        .modifier(RectangleWrapper(color: .yellow))
    }
}

struct AppleMusicWarningCard_Previews: PreviewProvider {
    static var previews: some View {
        AppleMusicWarningCard()
    }
}
