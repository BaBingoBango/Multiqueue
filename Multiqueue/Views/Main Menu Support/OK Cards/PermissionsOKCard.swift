//
//  PermissionsOKCard.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/2/22.
//

import SwiftUI

/// A card informing the user that there are no issues with the permissions settings.
struct PermissionsOKCard: View {
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .foregroundColor(.green)
                .padding(.top)
            Text("Permissions Status")
                .font(.title3)
                .fontWeight(.bold)
            Text("You've granted Multiqueue access to Local Network and Media & Apple Music permissions, which can be changed in the Settings app.")
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding([.bottom, .horizontal])
                .padding(.top, 1)
        }
        .modifier(RectangleWrapper(fixedHeight: 215, color: .green))
    }
}

struct PermissionsOKCard_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsOKCard()
    }
}
