//
//  RectangleWrapper.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/2/22.
//

import Foundation
import SwiftUI

struct RectangleWrapper: ViewModifier {
    
    var fixedHeight: Int?
    var color: Color?
    
    func body(content: Content) -> some View {
        ZStack {
            if fixedHeight == nil {
                Rectangle()
                    .foregroundColor(color == nil ? .primary : color!)
                    .opacity(0.1)
                    .cornerRadius(15)
            } else {
                Rectangle()
                    .foregroundColor(color == nil ? .primary : color!)
                    .frame(height: CGFloat(fixedHeight!))
                    .opacity(0.1)
                    .cornerRadius(15)
            }
            content
        }
    }
}
