//
//  SessionViewModel.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 28/12/2021.
//

import SwiftUI

class SessionViewModel: ObservableObject {
    @Published var session: Session
    
    @Published var secondsSinceQueue: Int
    @Published var secondsProgressed: Double = 0
    
    // For adding song to session toasts/alerts
    @Published var addedSongToSession = false
    @Published var addingSongToSession = false
    @Published var failedToAddSong = false
    @Published var copiedKey = false
    
    init(session: Session) {
        self.session = session
        if let lastQueue = UserDefaults.standard.object(forKey: "LAST_QUEUE") as? Date {
            secondsSinceQueue = Int(Date().timeIntervalSince(lastQueue))
        } else {
            secondsSinceQueue = Int.max
        }
        FirebaseManager.shared.listenToSession(id: session.id) { session in
            guard let session = session else {
                // TODO: Session is deleted
                FirebaseManager.shared.stopListeningToSession()
                return
            }
            DispatchQueue.main.async {
                self.session = session
            }
        }
    }
    
    var upcomingQueue: [Song] {
        let index = session.currentlyPlaying ?? 0
        return session.queue.suffix(session.queue.count - index)
    }
    
    func refresh() async {
        try? await FirebaseManager.shared.checkCurrentlyPlaying(id: session.id)
    }
    
    func addSongToQueue(_ song: Song) {
        addingSongToSession = true
        Task { @MainActor in
            do {
                try await FirebaseManager.shared.addSongToQueue(song, sessionId: session.id)
                addingSongToSession = false
                addedSongToSession = true
                updateAddSongToQueueButton()
            } catch {
                addingSongToSession = false
                failedToAddSong = true
            }
            checkCurrentlyPlaying()
        }
    }
    
    func updateAddSongToQueueButton() {
        UserDefaults.standard.setValue(Date(), forKey: "LAST_QUEUE")
        secondsSinceQueue = 0
        secondsProgressed = 0
    }
    
    func refreshSecondsSinceQueue() {
        if let lastQueue = UserDefaults.standard.object(forKey: "LAST_QUEUE") as? Date {
            secondsSinceQueue = Int(Date().timeIntervalSince(lastQueue))
            secondsProgressed = 0
        }
    }
    
    func checkCurrentlyPlaying() {
        Task {
            try! await FirebaseManager.shared.checkCurrentlyPlaying(id: session.id)
        }
    }
}
