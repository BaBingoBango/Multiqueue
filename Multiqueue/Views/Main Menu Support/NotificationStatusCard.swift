//
//  NotificationStatusCard.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 8/5/22.
//

import SwiftUI

struct NotificationStatusCard: View {
    
    var areNotificationsOn: Bool
    
    var body: some View {
        VStack {
            Image(systemName: areNotificationsOn ? "bell.badge.circle.fill" : "bell.slash.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .foregroundColor(.orange)
                .padding(.top)
            Text("Notifications \(areNotificationsOn ? "Enabled" : "Disabled")")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(verbatim: {
                if areNotificationsOn {
                    return "You'll see queue updates for active rooms in Notification Center."
                } else {
                    return "You won't see queue updates in Notification Center, but your music queue will still be updated from active rooms in the background."
                }
            }())
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding([.bottom, .horizontal])
                .padding(.top, 1)
        }
        .modifier(RectangleWrapper(fixedHeight: 215, color: .orange))
    }
}

struct NotificationStatusCard_Previews: PreviewProvider {
    static var previews: some View {
        NotificationStatusCard(areNotificationsOn: true)
    }
}