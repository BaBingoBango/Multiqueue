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
                .foregroundColor(.primary)
            Text("You've granted Multiqueue access to the Apple Music permission, which can be changed by tapping to visit the Settings app.")
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding([.bottom, .horizontal])
                .padding(.top, 1)
        }
        .modifier(RectangleWrapper(color: .green))
    }
}

struct PermissionsOKCard_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsOKCard()
    }
}
