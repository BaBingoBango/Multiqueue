//
//  RoomEmojiPickerView.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 7/29/22.
//

import SwiftUI

struct RoomEmojiPickerView: View {
    
    // MARK: - View Variables
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var roomColor: Color
    @Binding var enteredIcon: String
    let emojis = [
        0x1F601...0x1F64F,
        0x2702...0x27B0,
        0x1F680...0x1F6C0
    ].reduce([], +)
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4)) {
                    ForEach(emojis, id: \.self) { emojiCode in
                        Button(action: {
                            enteredIcon = String(UnicodeScalar(emojiCode)!)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            GeometryReader { geometry in
                                ZStack {
                                    Circle()
                                        .foregroundColor(roomColor)
                                        .opacity(0.3)
                                    
                                    Text(String(UnicodeScalar(emojiCode)!))
                                        .font(.system(size: geometry.size.height > geometry.size.width ? geometry.size.width * 0.6: geometry.size.height * 0.6))
                                }
                            }
                            .aspectRatio(contentMode: .fit)
                        }
                    }
                }
                .padding([.horizontal, .bottom])
            }
            
            // MARK: - Navigation View Settings
            .navigationTitle("Select Room Icon")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: { self.presentationMode.wrappedValue.dismiss() }) { Text("Cancel").fontWeight(.regular) })
        }
    }
}

struct RoomEmojiPickerView_Previews: PreviewProvider {
    static var previews: some View {
        RoomEmojiPickerView(roomColor: .red, enteredIcon: .constant("🎶"))
    }
}
