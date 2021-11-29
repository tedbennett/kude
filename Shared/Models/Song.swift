//
//  Song.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 29/11/2021.
//

import Foundation

struct Song: Codable, Identifiable {
    var id: String
    var name: String
    var artist: String
    var album: String
    var imageUrl: String
    var queuedBy: String?
    
    static var example = Song(
        id: "123",
        name: "Chicken Fried",
        artist: "Zac Brown Band",
        album: "The Foundation",
        imageUrl: "google.com"
    )
    
}
