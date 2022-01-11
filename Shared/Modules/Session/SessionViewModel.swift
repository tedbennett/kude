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
    
    init(session: Session) {
        self.session = session
        if let lastQueue = UserDefaults.standard.object(forKey: "LAST_QUEUE") as? Date {
            secondsSinceQueue = Int(Date().timeIntervalSince(lastQueue))
        } else {
            secondsSinceQueue = 0
        }
    }
}
