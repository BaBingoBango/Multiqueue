//
//  SearchBar.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/18/22.
//

import SwiftUI

/// A search bar text field used throughout the app.
struct SearchBar: View {
    
    // MARK: - View Variables
    /// The text entered in the field.
    @Binding var text: String
    /// Whether or not the user is editing the text.
    @State private var isEditing = false
    /// Whether or not the glass icon should be shown.
    let includeGlassIcon = true
    /// The placeholder text for the view.
    var placeholder = "Search"
    
    // MARK: - View Body
    var body: some View {
        HStack {
            
            TextField(placeholder, text: $text)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if isEditing {
                            Button(action: {
                                self.text = ""
                                
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                    
                    // Dismiss the keyboard
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
            }
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant(""))
    }
}
