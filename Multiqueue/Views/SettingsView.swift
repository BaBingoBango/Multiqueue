//
//  SettingsView.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/2/22.
//

import SwiftUI
import MessageUI

/// The view surfacing controls for various preferences of the app.
struct SettingsView: View {
    /// The horizontal size class of the current app environment.
    ///
    /// It is only relevant in iOS and iPadOS, since macOS and tvOS feature a consistent layout experience.
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.presentationMode) var presentationMode
    @State var isShowingMailSender = false
    @State var hasCopiedFeedbackEmail = false
    @State var isShowingUserGuide = false
    
    var body: some View {
        let settingsForm = Form {
            Section(header: Text("Permissions"), footer: Text("To grant or revoke Multiqueue permissions, tap to visit Settings.")) {
                Button(action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, completionHandler: { _ in })
                }) {
                    Text("Configure Multiqueue in Settings")
                }
            }
            
            Section(header: Text("Feedback")) {
                if MFMailComposeViewController.canSendMail() {
                    Button(action: {
                        isShowingMailSender = true
                    }) {
                        HStack { Image(systemName: "exclamationmark.bubble.fill").imageScale(.large); Text("Send Feedback Mail") }
                    }
                    .sheet(isPresented: $isShowingMailSender) {
                        MailSenderView(recipients: ["brook.patten_0n@icloud.com"], subject: "Multiqueue Feedback", body: "Please provide your feedback below. Feature suggestions, bug reports, and more are all appreciated! :)\n\n(If applicable, you may be contacted for more information or for follow-up questions.)\n\n\n")
                    }
                } else {
                    Button(action: {
                        UIPasteboard.general.string = "brook.patten_0n@icloud.com"
                        hasCopiedFeedbackEmail = true
                    }) {
                        HStack { Image(systemName: "exclamationmark.bubble.fill").imageScale(.large); Text(!hasCopiedFeedbackEmail ? "Copy Feedback Email" : "Feedback Email Copied!") }
                    }
                }
                
                Link(destination: URL(string: "https://apps.apple.com/us/app/multiqueue/id1604105691?action=write-review")!) {
                    HStack { Image(systemName: "star.bubble.fill").imageScale(.large); Text("Review on the App Store") }
                }
            }
            
            Section(header: Text("Resources")) {
                Button(action: {
                    isShowingUserGuide = true
                }) {
                    HStack { Image(systemName: "book.fill").imageScale(.large); Text("User Guide") }
                }
                .sheet(isPresented: $isShowingUserGuide) {
                    UserGuideView()
                }
                
                Link(destination: URL(string: "https://github.com/BaBingoBango/Multiqueue/wiki/Privacy-Policy")!) {
                    HStack { Image(systemName: "hand.raised.fill").imageScale(.large); Text("Privacy Policy") }
                }
                
                Link(destination: URL(string: "https://github.com/BaBingoBango/Multiqueue/wiki/Support-Center")!) {
                    HStack { Image(systemName: "questionmark.circle.fill").imageScale(.large); Text("Support Center") }
                }
                
                Link(destination: URL(string: "https://github.com/BaBingoBango/Multiqueue")!) {
                    HStack { Image(systemName: "curlybraces").imageScale(.large); Text("Multiqueue on GitHub") }
                }
            }
            
            Section(header: Text("About")) {
                HStack { Text("App Version"); Spacer(); Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String).foregroundColor(.secondary) }
                
                HStack { Text("Build Number"); Spacer(); Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String).foregroundColor(.secondary) }
            }
        }
        
        // MARK: Navigation View Settings
        .navigationTitle(Text("Settings"))
        .navigationBarItems(trailing: horizontalSizeClass != .compact ? AnyView(EmptyView()) : AnyView(Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Done").fontWeight(.bold)
        }))
        
        if horizontalSizeClass == .compact {
            NavigationView {
                settingsForm
                
            }
            .navigationViewStyle(StackNavigationViewStyle())
        } else {
            settingsForm
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
