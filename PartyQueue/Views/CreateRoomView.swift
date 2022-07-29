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
    @State var enteredIcon = "🎶"
    @State var enteredColor = Color.red
    @State var enteredDescription = ""
    
    @State var isShowingIconPicker = false
    
    // MARK: View Body
    var body: some View {
        NavigationView {
            Form {
                
                HStack {
                    Circle()
                        .aspectRatio(contentMode: .fit)
                        .hidden()
                    
                    GeometryReader { geometry in
                        ZStack {
                            Circle()
                                .foregroundColor(enteredColor)
                                .opacity(0.3)
                            
                            Text(enteredIcon)
                                .font(.system(size: geometry.size.height > geometry.size.width ? geometry.size.width * 0.6: geometry.size.height * 0.6))
                        }
                    }
                    .aspectRatio(contentMode: .fit)
                    
                    Circle()
                        .aspectRatio(contentMode: .fit)
                        .hidden()
                }
                    
                    .listRowBackground(Color(UIColor.systemGroupedBackground))
                
                Section(header: Text("Name")) {
                    TextField(defaultRoomName, text: $enteredName)
                }
                
                Section(header: Text("Customization")) {
                    Button(action: {
                        isShowingIconPicker = true
                    }) {
                        HStack {
                            Text("Room Icon")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(enteredIcon)
                            
                            Image(systemName: "chevron.right")
                                .font(Font.body.weight(.semibold))
                                .foregroundColor(.secondary)
                                .imageScale(.small)
                                .opacity(0.25)
                        }
                    }
                    .sheet(isPresented: $isShowingIconPicker) {
                        RoomEmojiPickerView(roomColor: enteredColor, enteredIcon: $enteredIcon)
                    }
                    
                    ColorPicker("Room Color", selection: $enteredColor)
                }
                
                Section(header: Text("Description"), footer: Text("All users you invite to this room will be able to view its name, icon, color, and optional description.")) {
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
                        let detailsRecord = CKRecord(recordType: "RoomDetails", recordID: CKRecord.ID(recordName: UUID().uuidString, zoneID: zone.zoneID))
                        
                        detailsRecord["Name"] = enteredName
                        detailsRecord["Description"] = enteredDescription
                        detailsRecord["Icon"] = enteredIcon
                        detailsRecord["Color"] = [
                            Double(enteredColor.cgColor!.components![0]),
                            Double(enteredColor.cgColor!.components![1]),
                            Double(enteredColor.cgColor!.components![2]),
                            Double(enteredColor.cgColor!.components![3])
                        ]
                        
                        let descriptionUploadOperation = CKModifyRecordsOperation(recordsToSave: [detailsRecord])
                        
                        descriptionUploadOperation.modifyRecordsResultBlock = { (_ secondOperationResult: Result<Void, Error>) -> Void in
                            switch secondOperationResult {
                            case .success():
                                let roomShareRecord = CKShare(recordZoneID: zone.zoneID)
                                let shareSaveOperation = CKModifyRecordsOperation(recordsToSave: [roomShareRecord])
                                
                                shareSaveOperation.modifyRecordsResultBlock = { (_ operationResult: Result<Void, Error>) -> Void in
                                    switch operationResult {
                                    case .success():
                                        presentationMode.wrappedValue.dismiss()
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                    }
                                }
                                
                                CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(shareSaveOperation)
                                
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
