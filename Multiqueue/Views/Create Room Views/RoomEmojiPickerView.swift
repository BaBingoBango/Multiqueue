//
//  RoomEmojiPickerView.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 7/29/22.
//

import SwiftUI

/// A view listing emoji options for a room.
struct RoomEmojiPickerView: View {
    
    // MARK: - View Variables
    /// The horizontal size class of the current app environment.
    ///
    /// It is only relevant in iOS and iPadOS, since macOS and tvOS feature a consistent layout experience.
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    /// The `PresentationMode` variable for this view.
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    /// The color of the current room.
    var roomColor: Color
    /// The icon the user has selected for the room.
    @Binding var enteredIcon: String
    /// Codes for emoji to display as options in this view.
    let emojis = [
        0x1F600...0x1F64F, // Emoticons
        0x1F300...0x1F5FF, // Misc Symbols and Pictographs
        0x1F680...0x1F6FF, // Transport and Map
        0x1F1E6...0x1F1FF, // Regional country flags
        0x2600...0x26FF,   // Misc symbols 9728 - 9983
        0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs 129280 - 129535
        9100...9300 // Misc items
    ].reduce([], +)
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: horizontalSizeClass == .compact ? 4 : 6)) {
                    ForEach(emojis, id: \.self) { emojiCode in
                        if Character(UnicodeScalar(emojiCode)!).unicodeAvailable() {
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
                                            .foregroundColor(.primary)
                                    }
                                }
                                .aspectRatio(contentMode: .fit)
                            }
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
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct RoomEmojiPickerView_Previews: PreviewProvider {
    static var previews: some View {
        RoomEmojiPickerView(roomColor: .red, enteredIcon: .constant("🎶"))
    }
}
