//
//  MessagingManager.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 29/11/2021.
//

import Foundation
import FirebaseMessaging
import MediaPlayer
import MusicKit

class MessagingManager: NSObject, MessagingDelegate {
    
    static let shared = MessagingManager()
    
    override private init() {
        super.init()
        Messaging.messaging().delegate = self
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print(fcmToken!)
    }
    
    func handleMessage(_ message: [AnyHashable: Any]) {
//        if let command = message["command"] as? String {
//            switch command {
//                case "play":
//                    MPMusicPlayerController.systemMusicPlayer.play()
//                case "pause":
//                    MPMusicPlayerController.systemMusicPlayer.pause()
//                case "next":
//                    MPMusicPlayerController.systemMusicPlayer.skipToNextItem()
//                case "previous":
//                    if MPMusicPlayerController.systemMusicPlayer.currentPlaybackTime > 5 {
//                        MPMusicPlayerController.systemMusicPlayer.skipToBeginning()
//                    } else {
//                        MPMusicPlayerController.systemMusicPlayer.skipToPreviousItem()
//                    }
//                case "seek":
//                    guard let value = message["timestamp"] as? String, let timestamp = Double(value) else { break }
//                    MPMusicPlayerController.systemMusicPlayer.currentPlaybackTime = timestamp
//                default: break
//            }
//        }
        
        if let id = message["id"] as? String,
           let name = message["name"] as? String,
           let artist = message["artist"] as? String,
           let album = message["album"] as? String,
           let imageUrl = message["imageUrl"] as? String,
           let queuedBy = message["queuedBy"] as? String,
           let sessionId = message["sessionId"] as? String{
            let song = Song(id: id, name: name, artist: artist, album: album, imageUrl: imageUrl, queuedBy: queuedBy)
            Task {
                do {
                    try await FirebaseManager.shared.addSongToQueue(song, sessionId: sessionId)
                } catch {
                    print("Failed to add to queue in Spotify")
                }
            }
            let descriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: [id])
            MPMusicPlayerController.systemMusicPlayer.append(descriptor)
        }
    }
    
    func test() {
    }
}
