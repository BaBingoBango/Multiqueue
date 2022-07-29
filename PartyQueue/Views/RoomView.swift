//
//  RoomView.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 7/29/22.
//

import SwiftUI
import CloudKit

struct RoomView: View {
    
    // MARK: - View Variables
    var room: (CKRecordZone, RoomDetails, CKShare)
    
    @State var isShowingMusicAdder = false
    @State var isShowingPeopleView = false
    @State var isShowingInfoView = false
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack {
                        HStack {
                            Text("Quick Info")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.leading)
                        
                        HStack {
                            Text("Current Song")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding([.top, .leading])
                        
                        SongRowView(title: "My Cool Song", subtitle: "Trendy Artist")
                        
                        Image(systemName: "arrow.up")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30)
                            .padding(.top)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Recently Added to Queue")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                        }
                        .padding([.top, .leading])
                        
                        ForEach(1...5, id: \.self) { entry in
                            SongRowView(title: "Cool Song", subtitle: "Cool Band", artwork: nil, subsubtitle: "Added by someone at some time")
                        }
                        
                    }
                }
                
                Button(action: {
                    isShowingMusicAdder.toggle()
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.accentColor)
                            .cornerRadius(15)
                            .frame(height: 55)
                        Text("Add Song to Queue")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .padding([.top, .leading, .trailing])
                .sheet(isPresented: $isShowingMusicAdder) {
                    MusicAdder()
                }
            }
            .padding(.bottom)
            
            // MARK: - Navigation View Settings
            .navigationTitle("My Room")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 25) {
                        Button(action: {
                            isShowingPeopleView = true
                        }) {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .foregroundColor(.accentColor)
                        }
                        .sheet(isPresented: $isShowingPeopleView) {
                            CloudKitSharingView(room: room, container: CKContainer(identifier: "iCloud.Multiqueue"))
                        }
                        
                        Button(action: {
                            isShowingInfoView = true
                        }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.accentColor)
                        }
                        .sheet(isPresented: $isShowingInfoView) {
                            EmptyView()
                        }
                    }
                }
            })
        }
    }
}

struct RoomView_Previews: PreviewProvider {
    static var previews: some View {
        RoomView(room: (CKRecordZone(zoneName: "Preview Zone"), RoomDetails(name: "Preview Room", icon: "🎶", color: .blue, description: "Preview description."), CKShare(recordZoneID: CKRecordZone.ID(zoneName: "Preview Zone", ownerName: "Preview Owner"))))
    }
}
