//
//  PermissionsHelpView.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/22/22.
//

import SwiftUI

struct PermissionsHelpView: View {
    var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading) {
                    
                    Text("What Are Permissions?")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Third-party apps you download from the App Store can help you as a user achieve all manner of tasks on your device. Most times, in order to accomplish these tasks, apps need to view or modify data on your device that lives in other apps. For privacy reasons, Apple requires users specifically give apps permission to access this information. These \"permissions\" help users like you control what personal information and device capabilities apps on your device can access.")
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("First-Time Use")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top)
                    
                    Text("When you first opened PartyQueue, you were presented with two alerts. Each one asked you to grant a permission to PartyQueue. Regardless of your initial choice, these alerts will never appear again; to modify your permission choices, visit Settings > Privacy. From there, choose permission you would like to edit and find PartyQueue in the list.")
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Why PartyQueue Needs Permissions")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top)
                    
                    Text("The main function of PartyQueue is to allow multiple devices to contribute to a single music queue on a single device. In order to accomplish this, PartyQueue firstly opens a local connection between the participant devices. Then, it allows these devices to look up songs from the Apple Music catalog. Finally, it facilitates the transfer of these songs between the devices. These tasks require use of your device's music information (to look up songs) and its connection capabilities (to interface with nearby devices). Thus, your authorization to use the Media & Apple Music and Local Network permissions are essential for PartyQueue to function.")
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Permission Warnings & Alerts")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top)
                    
                    Text("The world of privacy and permissions can be confusing, and it can be hard to tell which permissions are essential for an app and which are not. Since both permissions PartyQueue requests are essential, you'll see messages in red boxes on the main menu if either or both permissions are revoked. These messages inform you what permissions should be enabled and why PartyQueue needs the permissions.")
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("Allowing & Revoking Permissions")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top)
                    
                    Text("PartyQueue only needs its permissions when you're actively using the app and in a queue-sharing session. So if you perfer to disable PartyQueue's permissions when not using the app, and re-enable them when you are, please know that this will not affect your app experince in any way. Only note that if permissions are revoked while in a queue-sharing session, you may be kicked back to the main menu and the session may be closed abruptly.")
                        .fixedSize(horizontal: false, vertical: true)
                    
                }
                .multilineTextAlignment(.leading)
                
                .padding([.leading, .top])
                Spacer()
            }
        }
    }
}

struct PermissionsHelpView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsHelpView()
    }
}
