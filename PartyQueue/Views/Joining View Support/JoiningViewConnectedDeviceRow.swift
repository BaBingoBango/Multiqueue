//
//  JoiningViewConnectedDeviceRow.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/4/22.
//

import SwiftUI

struct JoiningViewConnectedDeviceRow: View {
    
    var text: String
    
    var body: some View {
        HStack {
            Text(text)
                .padding(.leading)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .imageScale(.large)
                .foregroundColor(.blue)
                .padding(.trailing)
        }
        .modifier(RectangleWrapper(fixedHeight: 50))
    }
}

struct JoiningViewConnectedDeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        JoiningViewConnectedDeviceRow(text: "Preview Device")
    }
}
