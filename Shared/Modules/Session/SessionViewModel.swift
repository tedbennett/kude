//
//  SessionViewModel.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 28/12/2021.
//

import SwiftUI

class SessionViewModel: ObservableObject {
    @Published var session: Session
    
    init(session: Session) {
        self.session = session
    }
    
}
