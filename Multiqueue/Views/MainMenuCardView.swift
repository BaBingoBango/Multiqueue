//
//  MainMenuCardView.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 8/7/22.
//

import SwiftUI

/// A card view with an icon and text that is shown on the Main Menu.
struct MainMenuCardView: View {
    // MARK: - View Variables
    /// Whether or not the colors in this view should be forced into monochrome.
    var isGray = true
    
    // MARK: - View Body
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
                .foregroundColor(isGray ? .gray : .blue)
            
            VStack(alignment: .leading) {
                Text("Host a Room")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Invite others to use your Apple Music subscription to add songs to your music queue.")
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(.all)
        .modifier(RectangleWrapper(color: isGray ? .gray : .blue))
    }
}

struct MainMenuCardView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuCardView()
    }
}
