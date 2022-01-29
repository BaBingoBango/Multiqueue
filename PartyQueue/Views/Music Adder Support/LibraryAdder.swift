//
//  LibraryAdder.swift
//  PartyQueue
//
//  Created by Ethan Marshall on 1/18/22.
//

import SwiftUI
import MediaPlayer
import MusicKit

struct LibraryAdder: View {
    
    @EnvironmentObject var multipeerServices: MultipeerServices
    @State var isShowingLibraryPicker = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                
                Picker("Choose a Play Type", selection: $multipeerServices.playType) {
                    ForEach(multipeerServices.playTypes, id: \.self) { playType in
                        if playType == .next {
                            Text("Play Songs Next")
                        } else {
                            Text("Play Songs Later")
                        }
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                HStack {
                    Image(systemName: "music.note.house.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.secondary)
                        .hidden()
                    Image(systemName: "music.note.house.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.secondary)
                    Image(systemName: "music.note.house.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.secondary)
                        .hidden()
                }
                .padding([.top, .leading, .trailing])
                
                Button(action: {
                    isShowingLibraryPicker.toggle()
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.accentColor)
                            .cornerRadius(15)
                            .frame(height: 55)
                        Text("Open Apple Music Library")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .padding([.top, .leading, .trailing])
                .sheet(isPresented: $isShowingLibraryPicker) {
                    SwiftUIMPMediaPickerController(multipeerServices: multipeerServices)
                }
                
                Spacer()
                
            }
            
            // MARK: - Navigation Bar Settings
            .navigationBarItems(trailing: Button(action: { self.presentationMode.wrappedValue.dismiss() }) { Text("Done").fontWeight(.bold) })
            .navigationBarTitle("Add from Library", displayMode: .inline)
            
        }
    }
}

struct LibraryAdder_Previews: PreviewProvider {
    static var previews: some View {
        LibraryAdder().environmentObject(MultipeerServices(isHost: true))
    }
}

struct SwiftUIMPMediaPickerController: UIViewControllerRepresentable {
    
    @ObservedObject var multipeerServices: MultipeerServices
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, multipeerServices)
    }
    
    func makeUIViewController(context: Context) -> MPMediaPickerController {
        // MARK: Library Picker Settings
        let mediaPickerController = MPMediaPickerController(mediaTypes: .music)
        mediaPickerController.delegate = context.coordinator
        mediaPickerController.allowsPickingMultipleItems = true
        mediaPickerController.prompt = "Select songs to send to the queue:"
        
        return mediaPickerController
    }
    
    func updateUIViewController(_ uiViewController: MPMediaPickerController, context: Context) {}
    
    class Coordinator: NSObject, MPMediaPickerControllerDelegate, UINavigationControllerDelegate {
        @ObservedObject var multipeerServices: MultipeerServices
        var parent: SwiftUIMPMediaPickerController
        init(_ mediaPickerController: SwiftUIMPMediaPickerController, _ multipeerServices: MultipeerServices) {
            self.parent = mediaPickerController
            self.multipeerServices = multipeerServices
        }
        
        // MARK: Media Picker Delegate
        func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
            print("Media items have been picked!")
            handleMediaItems(mediaItemCollection.items)
            mediaPicker.dismiss(animated: true)
        }
        func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
            print("The user cancelled the media picker!")
            mediaPicker.dismiss(animated: true)
        }
        
        func handleMediaItems(_ mediaItems: [MPMediaItem]) {
            for eachMediaItem in mediaItems {
                Task {
                    await multipeerServices.addSongsToQueueState(songs: [getSong(eachMediaItem)!])
                }
            }
        }
        
        @Sendable func getSong(_ mediaItem: MPMediaItem) async -> Song? {
            do {
                
                return try await MusicCatalogSearchRequest(term: mediaItem.title!, types: [Song.self]).response().songs[0]
                
            } catch {
                print(error.localizedDescription)
            }
            return nil
        }
        
    }
    
 }
