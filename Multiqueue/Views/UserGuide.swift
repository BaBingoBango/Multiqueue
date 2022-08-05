//
//  UserGuide.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/22/22.
//

import SwiftUI

struct UserGuide: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                
                NavigationLink(destination: HostingMusicQueueHelpView().navigationBarTitle("Hosting a Music Queue", displayMode: .inline)) {
                    Text("Hosting a Music Queue")
                }
                
                NavigationLink(destination: JoiningMusicQueueHelpView().navigationBarTitle("Joining a Music Queue", displayMode: .inline)) {
                    Text("Joining a Music Queue")
                }
                
                NavigationLink(destination: PermissionsHelpView().navigationBarTitle("Managing Permissions", displayMode: .inline)) {
                    Text("Managing Permissions")
                }
                
            }
            
            // MARK: - Navigation Bar Settings
            .navigationBarTitle("User Guide")
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done").fontWeight(.bold)
            })
        }
    }
}

struct UserGuide_Previews: PreviewProvider {
    static var previews: some View {
        UserGuide()
    }
}
