//
//  User.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 29/11/2021.
//

import Foundation

struct User: Codable, Identifiable {
    var id: String
    var name: String
    var host: Bool = false
    var session: String?
    
    init(id: String) {
        self.id = id
    }
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, imageUrl, host, session
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        if let name = try? container.decode(String.self, forKey: .name) {
            self.name = name
        }
        if let imageUrl = try? container.decode(String.self, forKey: .imageUrl) {
            self.imageUrl = imageUrl
        }
        if let session = try? container.decode(String.self, forKey: .session) {
            self.session = session
        }
        if let host = try? container.decode(Bool.self, forKey: .host) {
            self.host = host
        } else {
            host = false
        }
    }
}
