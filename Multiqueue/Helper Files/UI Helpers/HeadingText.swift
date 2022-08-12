//
//  HeadingText.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/21/22.
//

import SwiftUI

/// A small text view which bolds and left-aligns text.
struct HeadingText: View {
    
    // MARK: - View Variables
    /// The text the view should show.
    var text: String
    
    // MARK: - View Body
    var body: some View {
        
        HStack {
            Text(text)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.leading)
        
    }
}

struct HeadingText_Previews: PreviewProvider {
    static var previews: some View {
        HeadingText(text: "Preview Text")
    }
}
