//
//  AppleMusicOKCard.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/21/22.
//

import SwiftUI

struct AppleMusicOKCard: View {
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .foregroundColor(.green)
                .padding(.top)
            Text("Apple Music Status")
                .font(.title3)
                .fontWeight(.bold)
            Text("You've subscribed to Apple Music. This will be a description of what that means for you!")
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding([.bottom, .horizontal])
                .padding(.top, 1)
        }
        .modifier(RectangleWrapper(fixedHeight: 215, color: .green))
    }
}

struct AppleMusicOKCard_Previews: PreviewProvider {
    static var previews: some View {
        AppleMusicOKCard()
    }
}
