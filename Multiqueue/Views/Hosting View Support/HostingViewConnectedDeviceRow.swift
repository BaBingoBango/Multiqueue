//
//  HostingViewConnectedDeviceRow.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/3/22.
//

import SwiftUI

struct HostingViewConnectedDeviceRow: View {
    
    var text: String
    var showInvite = true
    
    var body: some View {
        HStack {
            Text(text)
                .padding(.leading)
                .foregroundColor(.primary)
            Spacer()
            if showInvite {
                Text("Invite")
                    .foregroundColor(.blue)
                    .fontWeight(.bold)
                    .padding(.trailing)
            }
//            Image(systemName: "ellipsis.circle")
//                .imageScale(.large)
//                .foregroundColor(.blue)
//                .padding(.trailing)
        }
        .modifier(RectangleWrapper(fixedHeight: 50))
    }
}

struct HostingViewConnectedDeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        HostingViewConnectedDeviceRow(text: "Preview Device")
    }
}
