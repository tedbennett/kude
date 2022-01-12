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
        
        let font = UIFont.systemFont(ofSize: 32, weight: .bold)
        let descriptor = font.fontDescriptor.withDesign(.rounded)!
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor.systemPurple,
            .font: UIFont(descriptor: descriptor, size: 34)
        ]
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            .tint(Color(uiColor: .systemPurple))
        }
    }
}
