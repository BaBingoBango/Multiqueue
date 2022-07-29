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
    @State var userRooms: [CKRecordZone : RoomDetails] = [:]
    
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
                    
                    ForEach(Array(userRooms.values), id: \.self) { eachRoomDetails in
                        NavigationLink(destination: EmptyView()) {
                            RoomOptionView(roomDetails: eachRoomDetails)
                        }
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
            .onAppear {
                let zoneFetchOperation = CKFetchRecordZonesOperation.fetchAllRecordZonesOperation()
                
                zoneFetchOperation.perRecordZoneResultBlock = { (_ recordZoneID: CKRecordZone.ID, _ recordZoneResult: Result<CKRecordZone, Error>) -> Void in
                    switch recordZoneResult {
                    case .success(let zone):
                        let detailsQueryOperation = CKQueryOperation(query: CKQuery(recordType: "RoomDetails", predicate: NSPredicate(value: true)))
                        detailsQueryOperation.zoneID = zone.zoneID
                        
                        detailsQueryOperation.recordMatchedBlock = { (_ recordID: CKRecord.ID, _ recordResult: Result<CKRecord, Error>) -> Void in
                            switch recordResult {
                            case .success(let queriedRecord):
                                let roomDetails = RoomDetails(
                                    name: queriedRecord["Name"] as! String,
                                    icon: queriedRecord["Icon"] as! String,
                                    color: Color(.sRGB, red: (queriedRecord["Color"] as! [Double])[0], green: (queriedRecord["Color"] as! [Double])[1], blue: (queriedRecord["Color"] as! [Double])[2], opacity: (queriedRecord["Color"] as! [Double])[3]),
                                    description: queriedRecord["Description"] as! String
                                )
                                
                                userRooms[zone] = roomDetails
                                
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                        
                        CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(detailsQueryOperation)
                        
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
