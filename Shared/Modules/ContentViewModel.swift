//
//  ContentViewModel.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 30/11/2021.
//

import SwiftUI

class ContentViewModel: ObservableObject {
    
    @Published var loading = true
    var session: Session?
    
    init() {
        Task { [weak self] in
            let session = await UserManager.shared.checkSession()
            await self?.update(session)
        }
    }
    
    @MainActor
    func update(_ session: Session?) {
        loading = false
        self.session = session
    }
}
