//
//  Session.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 29/11/2021.
//

import Foundation

struct Session: Codable {
    var id: String
    var name: String
    var host: String
    var members: [User]
    var queue: [Song]
    var createdAt: Date
    var key: String
    var spotifyKey: String?
    var appleMusicKey: String?
    
    var currentlyPlaying: Int?
    var delay: Int = 0 // Number of seconds between adding songs
    
    var url: URL {
        return URL(string: "https://www.kude.app/session/\(id)")!
    }
    
    static let example = Session(id: "", name: "New Session", host: "host-id", members: [User(id: "123", name: "James"), User(id: "1234", name: "Donny")], queue: [], createdAt: Date(), key: "ABCDEF")
}
