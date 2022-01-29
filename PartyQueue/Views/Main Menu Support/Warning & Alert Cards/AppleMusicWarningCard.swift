//
//  AppleMusicWarningCard.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/21/22.
//

import SwiftUI

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
            Text("This will be a description of how app usage is limited by not being an Apple Music subscriber.")
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding([.bottom, .horizontal])
                .padding(.top, 1)
        }
        .modifier(RectangleWrapper(fixedHeight: 215, color: .yellow))
    }
}

struct AppleMusicWarningCard_Previews: PreviewProvider {
    static var previews: some View {
        AppleMusicWarningCard()
    }
}
