//
//  UserGuideView.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 8/5/22.
//

import SwiftUI

/// A view providing users information about using the app.
struct UserGuideView: View {
    
    // MARK: - View Variables
    /// The system `PresentationMode` variable for this view.
    @SwiftUI.Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Setup")) {
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                Multiqueue allows users to transmit song data over the internet by way of the iCloud private database.

                                Thus, in order to use Multiqueue, you’ll need to be signed in to an Apple ID on your device, which will enable you to authenticate with Apple’s iCloud servers.

                                To sign in, or check your account information, navigate to your device’s settings and select either the prompt to sign in, or your name, at the top of the view.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Signing in to iCloud")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "icloud").imageScale(.large); Text("Signing in to iCloud") }
                    }
                    
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                When you opened Multiqueue for the first time, you were presented with two requests for system permissions.

                                Firstly, you were asked to provide access to the Media & Apple Music permission, which is required for Multiqueue to work. This permission enables Multiqueue to query Apple Music for song data, enabling the add by search, library, and link features.

                                You were also asked to enable notifications for Multiqueue. This is an entirely optional permission that, when enabled, shows notifications in Notification Center when your music queue is updated by another user via an active room.

                                To adjust your permission settings, navigate to the Multiqueue section in the Settings app, or tap on the notification status card.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Setting Permissions")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "hand.raised.fill").imageScale(.large); Text("Setting Permissions") }
                    }
                    
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                Multiqueue allows multiple users to contribute to a single user’s Apple Music queue. Thus, while Apple Music is not required for contributing, it is required in order to be a person contributed to, that is, a host.

                                In short, in order to host rooms, an Apple Music subscription is required. This is because when you receive the data for a song to be added from another user, it does not actually contain the audio file for that song. Rather, the song’s metadata, such as its title, its artist’s name, and its Apple Music ID are transmitted.

                                Multiqueue then uses this ID to add the corresponding Apple Music song to your queue by using your subscription.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Apple Music")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "music.note").imageScale(.large); Text("Apple Music") }
                    }
                }
                
                Section(header: Text("Hosting a Room")) {
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                The first step in opening your music queue to other users is to create a room. A room is a central place for users to gather and transmit queue data.

                                To create a room, tap Host a Room, then select Create Room. From there, you can provide a name, icon, color, and description for your room. This information is visible to all room participants and helps to identify your room from others.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Creating a Room")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "plus").imageScale(.large); Text("Creating a Room") }
                    }
                    
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                To manage the participants in your room, tap on the room in the list of your rooms. From there, tap the portrait icon in the top-right corner to open the Sharing view.

                                From this screen, you can add participants, remove participants, and change the permissions for your room. If you choose the “View only” permission, participants will not be able to contribute to your queue.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Managing Participants")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "person.crop.circle.fill.badge.plus").imageScale(.large); Text("Managing Participants") }
                    }
                    
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                To edit your room’s data, tap the information icon in the top-right corner of the room’s screen. From there, you can modify your room’s active state, song limit, time limit, icon, color, and description.

                                Any changes you make will be uploaded and sent to all other participants.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Edit a Room")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "pencil").imageScale(.large); Text("Edit a Room") }
                    }
                    
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                Room Limits give you an additional layer of control over your music queue and your room. Song limits perform an action when a certain number of songs are added, while time limits perform an action when their countdowns reach zero.

                                To set a limit, tap the information icon in the top-right corner of the room’s screen. From there, toggle on the limit you would like to set and select either Set Song Limit or Set Time Limit. You can also select the action that takes place when limits expires on this screen.

                                You can monitor limits from this information screen or from the main room view.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Set Room Limits")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "clock.fill").imageScale(.large); Text("Set Room Limits") }
                    }
                    
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                To delete a room, tap the information icon in the top-right corner of the room’s screen. From there, select Delete Room, and confirm your choice on the resulting dialog.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Delete a Room")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "trash.fill").imageScale(.large); Text("Delete a Room") }
                    }
                }
                
                Section(header: Text("Joining a Room")) {
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                The first step to contributing to someone else’s Apple Music queue is to open their invitation link. When you do this, Multiqueue will launch and display a “Accepting Room Invitation…” alert.

                                If you don’t stop the acceptance by tapping Cancel, the room will be added to your accepted room list.

                                You may need to refresh the Join Room screen in order to see your invitation’s room appear in the list.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Accepting an Invitation")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "envelope.fill").imageScale(.large); Text("Accepting an Invitation") }
                    }
                    
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                To open a room you’ve been invited to, select Join a Room on the main menu. You will then be brought to that room’s main screen, where you can add songs to the queue, view the song Now Playing, and view the room’s information.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Opening a Room")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "envelope.open.fill").imageScale(.large); Text("Opening a Room") }
                    }
                    
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                To leave a room you’ve been invited to, first open the room from the Join Room list. From there, tap the portrait icon in the top-right corner to open the Sharing view. You can then select Remove Me to remove yourself from the room.

                                If you leave a room, you won’t be able to access it unless you re-open an invitation link.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Leaving a Room")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "figure.walk").imageScale(.large); Text("Leaving a Room") }
                    }
                }
                
                Section(header: Text("Adding Music")) {
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                To add music to the room’s queue by way of your Apple Music library, select the Library tab from the Add Music screen. From there, tap the button to open your library and add music you’ve added to your library.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Adding via Library")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "books.vertical.fill").imageScale(.large); Text("Adding via Library") }
                    }
                    
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                To search the Apple Music catalog for music to add to the queue, select the Search tab from the Add Music screen. From there, type in the search field to find music. Then, select any of the songs to add them to your queue.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Adding via Search")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "magnifyingglass").imageScale(.large); Text("Adding via Search") }
                    }
                    
                    NavigationLink(destination: {
                        ScrollView {
                            Text(verbatim: {
                                """
                                You can add a song to a room’s queue using an Apple Music link. First, select the Link tab from the Add Music screen. From there, paste your link in the search bar, which will display your song. Then, tap your song to add it to the queue.
                                """
                            }())
                            .padding()
                        }
                        .navigationTitle("Adding via Link")
                        .navigationBarTitleDisplayMode(.inline)
                    }) {
                        HStack { Image(systemName: "link").imageScale(.large); Text("Adding via Link") }
                    }
                }
            }
            
            // MARK: - Navigation View Settings
            .navigationTitle("User Guide")
            .navigationBarItems(trailing: Button(action: { self.presentationMode.wrappedValue.dismiss() }) { Text("Done").fontWeight(.bold) })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct UserGuideView_Previews: PreviewProvider {
    static var previews: some View {
        UserGuideView()
    }
}
