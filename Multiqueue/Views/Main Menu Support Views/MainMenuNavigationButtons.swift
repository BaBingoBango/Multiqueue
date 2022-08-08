//
//  MainMenuNavigationButtons.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/2/22.
//

import SwiftUI

struct MainMenuNavigationButtonsR: View {
    
    @State var showingSettings = false
    
    var body: some View {
        HStack {
            
            Button(action: {
                showingSettings.toggle()
            }) {
                Image(systemName: "gear")
                    .foregroundColor(.accentColor)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            
        }
    }
}
