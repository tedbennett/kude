//
//  kudeApp.swift
//  Shared
//
//  Created by Ted Bennett on 28/11/2021.
//

import SwiftUI
import Firebase

@main
struct kudeApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().onOpenURL { url in
                print("Hey")
            }
        }
    }
}
