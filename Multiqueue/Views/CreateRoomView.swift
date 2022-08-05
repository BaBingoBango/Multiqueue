//
//  CreateRoomView.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 7/24/22.
//

import SwiftUI
import CloudKit
import MusicKit

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
    @State var enteredColor: Color = .red
    @State var enteredDescription = ""
    
    @State var isShowingIconPicker = false
    
    @State var roomUploadStatus = OperationStatus.notStarted
    
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
            .navigationBarItems(leading: Button(action: { self.presentationMode.wrappedValue.dismiss() }) { Text("Cancel").fontWeight(.regular) }, trailing: roomUploadStatus == .inProgress || roomUploadStatus == .success ? AnyView(ProgressView().progressViewStyle(CircularProgressViewStyle())) : AnyView(Button(action: {
                roomUploadStatus = .inProgress
                
                let zoneCreationDate = Date()
                let zoneUUID = UUID()
                let newZone = CKRecordZone(zoneName: "\(enteredName == "" ? defaultRoomName : enteredName) [\(zoneCreationDate.description)] [\(zoneUUID)]")
                
                let zoneUploadOperation = CKModifyRecordZonesOperation(recordZonesToSave: [newZone])
                
                zoneUploadOperation.perRecordZoneSaveBlock = { (_ recordZoneID: CKRecordZone.ID, _ saveResult: Result<CKRecordZone, Error>) -> Void in
                    switch saveResult {
                    case .success(let zone):
                        let detailsRecord = CKRecord(recordType: "RoomDetails", recordID: CKRecord.ID(recordName: UUID().uuidString, zoneID: zone.zoneID))
                        detailsRecord["IsActive"] = 1
                        detailsRecord["HostOnScreen"] = 0
                        detailsRecord["Name"] = enteredName
                        detailsRecord["Description"] = enteredDescription
                        detailsRecord["Icon"] = enteredIcon
                        detailsRecord["Color"] = [
                            Double(enteredColor.cgColor?.components![0] ?? 1),
                            Double(enteredColor.cgColor?.components![1] ?? 0),
                            Double(enteredColor.cgColor?.components![2] ?? 0),
                            Double(enteredColor.cgColor?.components![3] ?? 1)
                        ]
                        detailsRecord["SongLimit"] = 0
                        detailsRecord["SongLimitAction"] = "Deactivate Room"
                        detailsRecord["TimeLimit"] = 0
                        detailsRecord["TimeLimitAction"] = "Deactivate Room"
                        
                        let nowPlayingRecord = CKRecord(recordType: "NowPlayingSong",  recordID: CKRecord.ID(recordName: UUID().uuidString, zoneID: zone.zoneID))
                        nowPlayingRecord["PlayingSong"] = try! JSONEncoder().encode(SystemMusicPlayer.shared.queue.currentEntry?.item)
                        nowPlayingRecord["TimeElapsed"] = systemPlayingSongTime.0
                        nowPlayingRecord["SongTime"] = systemPlayingSongTime.1
                        
                        let artworkURL = systemPlayingSong?.artwork?.url(width: 50, height: 50)
                        let artworkFilename = FileManager.default.temporaryDirectory.appendingPathComponent("artwork.png")
                        if artworkURL != nil {
                            try! UIImage(data: Data(contentsOf: artworkURL!), scale: UIScreen.main.scale)!.pngData()!.write(to: artworkFilename)
                            nowPlayingRecord["AlbumArtwork"] = CKAsset(fileURL: artworkFilename)
                        }
                        
                        let roomRecordsUploadOperation = CKModifyRecordsOperation(recordsToSave: [detailsRecord, nowPlayingRecord])
                        
                        roomRecordsUploadOperation.modifyRecordsResultBlock = { (_ secondOperationResult: Result<Void, Error>) -> Void in
                            switch secondOperationResult {
                            case .success():
                                // Delete the artwork file to save space
                                do {
                                    try FileManager.default.removeItem(at: artworkFilename)
                                } catch {}
                                
                                let subscription = CKQuerySubscription(recordType: "QueueSong",
                                                                       predicate: NSPredicate(value: true),
                                                                       subscriptionID: "\(enteredName == "" ? defaultRoomName : enteredName) Subscription [\(zoneCreationDate.description)] [\(zoneUUID)]",
                                                                       options: .firesOnRecordCreation)
                                subscription.zoneID = zone.zoneID
                                
                                let notificationInfo = CKSubscription.NotificationInfo()
                                notificationInfo.shouldSendContentAvailable = true
                                notificationInfo.desiredKeys = ["RecordName", "ZoneName", "ZoneOwnerName"]
                                subscription.notificationInfo = notificationInfo
                                
                                let subscriptionUploadOperation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription])
                                
                                subscriptionUploadOperation.perSubscriptionSaveBlock = { (_ subscriptionID: CKSubscription.ID, _ subscriptionSaveResult: Result<CKSubscription, Error>) -> Void in
                                    switch subscriptionSaveResult {
                                        
                                    case .success(_):
                                        let roomShareRecord = CKShare(recordZoneID: zone.zoneID)
                                        roomShareRecord[CKShare.SystemFieldKey.title] = enteredName as CKRecordValue
                                        roomShareRecord[CKShare.SystemFieldKey.shareType] = "Room" as CKRecordValue
                                        roomShareRecord[CKShare.SystemFieldKey.thumbnailImageData] = NSDataAsset(name: "Rounded App Icon")!.data as CKRecordValue
                                        roomShareRecord.publicPermission = .readWrite

                                        let shareSaveOperation = CKModifyRecordsOperation(recordsToSave: [roomShareRecord])
                                        shareSaveOperation.modifyRecordsResultBlock = { (_ operationResult: Result<Void, Error>) -> Void in
                                            switch operationResult {
                                            case .success():
                                                roomUploadStatus = .success
                                                presentationMode.wrappedValue.dismiss()

                                            case .failure(let error):
                                                print(error.localizedDescription)
                                                roomUploadStatus = .failure
                                            }
                                        }

                                        shareSaveOperation.qualityOfService = .userInteractive
                                        CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(shareSaveOperation)
                                        
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                    }
                                }
                                
                                subscriptionUploadOperation.qualityOfService = .userInteractive
                                CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(subscriptionUploadOperation)
                                
                            case .failure(let error):
                                print(error.localizedDescription)
                                roomUploadStatus = .failure
                            }
                        }
                        
                        roomRecordsUploadOperation.qualityOfService = .userInteractive
                        CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(roomRecordsUploadOperation)
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        roomUploadStatus = .failure
                    }
                }
                
                zoneUploadOperation.qualityOfService = .userInteractive
                CKContainer(identifier: "iCloud.Multiqueue").privateCloudDatabase.add(zoneUploadOperation)
            }) { Text("Save").fontWeight(.bold) }))
        }
    }
}

struct CreateRoomView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRoomView()
    }
}
