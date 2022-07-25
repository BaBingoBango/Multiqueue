//
//  CreateRoomView.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 7/24/22.
//

import SwiftUI
import CloudKit

struct CreateRoomView: View {
    // MARK: View Variables
    @SwiftUI.Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    var defaultRoomName: String {
        if CKCurrentUserDefaultName != "__defaultOwner__" {
            return "\(CKCurrentUserDefaultName)'s Room"
        } else {
            return "My Room"
        }
    }
    @State var enteredName = ""
    @State var enteredDescription = ""
    
    // MARK: View Body
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField(defaultRoomName, text: $enteredName)
                }
                
                Section(header: Text("Description"), footer: Text("All users you invite to this room will be able to view the optional description.")) {
                    TextEditor(text: $enteredDescription)
                        .frame(height: 100)
                }
            }
            
            // MARK: Navigation View Settings
            .navigationTitle(Text("New Room"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: { self.presentationMode.wrappedValue.dismiss() }) { Text("Cancel").fontWeight(.regular) }, trailing: Button(action: {
                let newZone = CKRecordZone(zoneName: "\(enteredName == "" ? defaultRoomName : enteredName) [\(Date().description)] [\(UUID())]")
                
                let zoneUploadOperation = CKModifyRecordZonesOperation(recordZonesToSave: [newZone])
                
                zoneUploadOperation.perRecordZoneSaveBlock = { (_ recordZoneID: CKRecordZone.ID, _ saveResult: Result<CKRecordZone, Error>) -> Void in
                    switch saveResult {
                    case .success(let zone):
                        let descriptionRecord = CKRecord(recordType: "RoomDescription", recordID: CKRecord.ID(recordName: UUID().uuidString, zoneID: zone.zoneID))
                        descriptionRecord["Description"] = enteredDescription
                        
                        let descriptionUploadOperation = CKModifyRecordsOperation(recordsToSave: [descriptionRecord])
                        
                        descriptionUploadOperation.modifyRecordsResultBlock = { (_ secondOperationResult: Result<Void, Error>) -> Void in
                            switch secondOperationResult {
                            case .success():
                                presentationMode.wrappedValue.dismiss()
                                
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                        
                        CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(descriptionUploadOperation)
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                
                CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(zoneUploadOperation)
            }) { Text("Save").fontWeight(.bold) })
        }
    }
}

struct CreateRoomView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRoomView()
    }
}
