//
//  MyRoomsView.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 7/24/22.
//

import SwiftUI
import CloudKit

/// The view listing the user's created rooms
struct MyRoomsView: View {
    
    // MARK: View Variables
    @State var isShowingCreateRoomView = false
    @State var userRooms: [CKRecordZone] = []
    
    // MARK: View Body
    var body: some View {
//        NavigationView {
            ScrollView {
                VStack {
                    Button(action: {
                        isShowingCreateRoomView = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.white)
                            
                            Text("Create Room")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                        .modifier(RectangleWrapper(fixedHeight: 50, color: .red, opacity: 1.0))
                    }
                    .padding()
                    .sheet(isPresented: $isShowingCreateRoomView) {
                        CreateRoomView()
                    }
                    
                    ForEach(userRooms, id: \.self) { eachRoom in
                        Text(eachRoom.zoneID.description)
                    }
                }
            }
            .onAppear {
                let zoneFetchOperation = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
                
                zoneFetchOperation.perRecordZoneResultBlock = { (_ recordZoneID: CKRecordZone.ID, _ recordZoneResult: Result<CKRecordZone, Error>) -> Void in
                    switch recordZoneResult {
                    case .success(let zone):
                        userRooms.append(zone)
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                
                CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(zoneFetchOperation)
            }
            
            // MARK: Navigation View Settings
            .navigationTitle(Text("My Rooms"))
//        }
    }
}

struct MyRoomsView_Previews: PreviewProvider {
    static var previews: some View {
        MyRoomsView()
    }
}
