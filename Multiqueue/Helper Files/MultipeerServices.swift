//
//  MultipeerServices.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 1/4/22.
//

import Foundation
import MultipeerConnectivity
import MusicKit

class MultipeerServices: NSObject, ObservableObject {
    
    typealias MusicItemReceivedHandler = (PlayableMusicItem) -> Void
    
    let session: MCSession
    var isHost: Bool
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private static let service = "partyqueue"
    private let musicItemReceivedHandler: MusicItemReceivedHandler?
    private var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
    @Published var discoveredDevices: [MCPeerID] = []
    @Published var connectedDevices: [MCPeerID] = []
    private var nearbyServiceBrowser: MCNearbyServiceBrowser
    @Published var queueState: QueueState = QueueState(currentSong: SongState(title: SystemMusicPlayer.shared.queue.currentEntry?.title ?? "No Current Song", artist: SystemMusicPlayer.shared.queue.currentEntry?.description.components(separatedBy: "artistName: \"")[1].components(separatedBy: "\"))")[0] ?? ""), addedToQueue: [])
    @Published var playType: PlayType = .later
    var playTypes: [PlayType] = [.next, .later]
    @Published var isSongLimit = false
    @Published var isTimeLimit = false
    @Published var songLimit = 20
    @Published var timeLimit = 5 // In minutes

    init(_ musicItemReceivedHandler: MusicItemReceivedHandler? = nil, isHost: Bool) {
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .none)
        self.musicItemReceivedHandler = musicItemReceivedHandler
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: MultipeerServices.service)
        nearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: MultipeerServices.service)
        self.isHost = isHost
        super.init()
        nearbyServiceAdvertiser.delegate = self
        nearbyServiceBrowser.delegate = self
        session.delegate = self
    }
    
    var isReceivingData: Bool = false {
      didSet {
        if isReceivingData {
          nearbyServiceAdvertiser.startAdvertisingPeer()
          print("Started advertising!")
        } else {
          nearbyServiceAdvertiser.stopAdvertisingPeer()
          print("Stopped advertising!")
        }
      }
    }
    
    func startBrowsing() {
      nearbyServiceBrowser.startBrowsingForPeers()
    }

    func stopBrowsing() {
      nearbyServiceBrowser.stopBrowsingForPeers()
    }
    
    func invitePeer(_ peerID: MCPeerID) {
        let context = "Verified Multiqueue Request".data(using: .utf8)
        nearbyServiceBrowser.invitePeer(peerID, to: session, withContext: context, timeout: TimeInterval(120))
    }
    
    func addSongsToQueueState(songs: [Song]) {
        
        for eachSong in songs {
            queueState.addedToQueue.append(QueueEntry(song: eachSong, timeAdded: Date(), adder: session.myPeerID.displayName, playType: playType))
        }
        
        print("(1) Updated local queue state to a queueState with \(queueState.addedToQueue.count) added to queue!")
        
        // Send the new queueState to all other devices
        do {
            try session.send(JSONEncoder().encode(queueState), toPeers: session.connectedPeers, with: .reliable)
            print("(2) Succesfully sent queue state!")
        } catch {
            print("Error sending queue state from MusicAdder.swift!")
            print(error.localizedDescription)
        }
        
        // If the device is the host, update the system music queue
        if isHost {
            @Sendable func updateSystemQueueAsync() async {
                do {
                    try await SystemMusicPlayer.shared.queue.insert(queueState.addedToQueue.last!.song, position: queueState.addedToQueue.last!.playType == .next ? .afterCurrentEntry : .tail)
                } catch {
                    print("Error in adding to system music player queue!")
                    print(error.localizedDescription)
                }
            }
            func updateSystemQueue() {
                Task {
                    await updateSystemQueueAsync()
                }
            }
            updateSystemQueue()
        }
        
    }
    
}

// MARK: - Transmission Delegate
extension MultipeerServices: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
      switch state {
      case .connected:
          print("Connected to \"\(peerID.displayName)\"")
          
          // Update connectedDevices
          if let index = discoveredDevices.firstIndex(of: peerID) { discoveredDevices.remove(at: index) }
          connectedDevices.append(peerID)
          
          // Transmit the host's queue to the participants
          if isHost {
              do {
                  try session.send(JSONEncoder().encode(queueState), toPeers: session.connectedPeers, with: .reliable)
                  print("(2) Succesfully sent queue state!")
              } catch {
                  print("Error sending queue state from MusicAdder.swift!")
                  print(error.localizedDescription)
              }
          }
          
      case .notConnected:
          print("Not connected to \"\(peerID.displayName)\"!")
          if connectedDevices.contains(peerID) {
              connectedDevices.remove(at: connectedDevices.firstIndex(of: peerID)!)
          }
      case .connecting:
          print("Connecting to \"\(peerID.displayName)\"...")
      @unknown default:
          print("Unknown state: \(state)")
      }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        // MARK: QueueState Reception Handler
        do {
            let receivedQueueState = try JSONDecoder().decode(QueueState.self, from: data)
            queueState = receivedQueueState
            print("(3) Succesfully updated queue state!")
            print(queueState)
            
            if isHost {
                @Sendable func updateSystemQueueAsync() async {
                    do {
                        try await SystemMusicPlayer.shared.queue.insert(queueState.addedToQueue.last!.song, position: queueState.addedToQueue.last!.playType == .next ? .afterCurrentEntry : .tail)
                    } catch {
                        print("Error in adding to system music player queue!")
                        print(error.localizedDescription)
                    }
                }
                func updateSystemQueue() {
                    Task {
                        await updateSystemQueueAsync()
                    }
                }
                updateSystemQueue()
            }
        } catch {
            print("Error decoding received QueueState in MultipeerServices.swift!")
            print(error.localizedDescription)
            
            do {
                
                // MARK: Limit Signal Handler
                let receivedLimitPack = try JSONDecoder().decode(LimitInfoPack.self, from: data)
                isSongLimit = receivedLimitPack.isSongLimit
                songLimit = receivedLimitPack.songLimit
                isTimeLimit = receivedLimitPack.isTimeLimit
                timeLimit = receivedLimitPack.timeLimit
                
            } catch {
                //
                
                let receivedString = String(data: data, encoding: .utf8)
                if receivedString == "DISCONNECT SIGNAL" {
                    self.stopBrowsing()
                    self.isReceivingData = false
                    self.session.disconnect()
                    self.connectedDevices = []
                    self.discoveredDevices = []
                    self.queueState = QueueState(currentSong: SongState(title: SystemMusicPlayer.shared.queue.currentEntry?.title ?? "No Current Song", artist: SystemMusicPlayer.shared.queue.currentEntry?.description.components(separatedBy: "artistName: \"")[1].components(separatedBy: "\"))")[0] ?? ""), addedToQueue: [])
                }
            }
            
        }
        
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
}

// MARK: - Advertiser Delegate
extension MultipeerServices: MCNearbyServiceAdvertiserDelegate {
    
  func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
      print("An invitation from \"\(peerID.displayName)\" was received!")
      invitationHandler(true, self.session)
  }
    
}

// MARK: - Browser Delegate
extension MultipeerServices: MCNearbyServiceBrowserDelegate {
    
  func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
      print("The peer \"\(peerID.displayName)\" has been found!")
      if !discoveredDevices.contains(peerID) {
          discoveredDevices.append(peerID)
    }
  }

  func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
      print("The peer \"\(peerID.displayName)\" was lost.")
      guard let index = discoveredDevices.firstIndex(of: peerID) else { return }
      discoveredDevices.remove(at: index)
  }
    
}
