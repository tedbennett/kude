//
//  FirebaseManager.swift
//  kude
//
//  Created by Ted Bennett on 29/11/2021.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseFirestoreCombineSwift
import FirebaseFunctions

class FirebaseManager {
    static var shared = FirebaseManager()
    
    private init() { }
    
    private var listener: ListenerRegistration?
    private var db = Firestore.firestore()
    lazy private var functions = Functions.functions()

    // ========================================================================
    // MARK: Sessions
    // ========================================================================
    
    func getSession(id: String) async throws -> Session {
        let doc = try await db.collection("sessions").document(id).getDocument()
        guard let data = doc.data() else { throw ApiError.noData }
        let session: Session = try decode(data)
        return session
    }
    
    func getSession(key: String) async throws -> Session {
        let doc = try await db.collection("sessions").whereField("key", isEqualTo: key).getDocuments()
        guard let data = doc.documents.first?.data() else { throw ApiError.noData }
        let session: Session = try decode(data)
        return session
    }
 
    func createSession() async throws -> Session {
        let user = UserManager.shared.user
        let id = UUID().uuidString
        let key = String(id.prefix(6))
        try await db.collection("sessions").document(id).setData([
            "id": id,
            "key": key,
            "name": "\(user.name)'s Session",
            "host": user.id,
            "members": [
                [
                    "id": user.id,
                    "name": user.name
                ],
            ],
            "queue": [],
            "delay": 0,
            "createdAt": Date().timeIntervalSince1970,
            "updatedAt": Date().timeIntervalSince1970
        ])
        return try await getSession(id: id)
    }
    
    func updateSession(id: String, name: String, delay: Int) async throws {
        try await db.collection("sessions").document(id).updateData([
            "name": name,
            "delay": delay,
            "updatedAt": Date().timeIntervalSince1970
        ])
    }
    
    func deleteSession(id: String) async throws {
        let session = try await getSession(id: id)
        for user in session.members {
            try await db.collection("users").document(user.id).updateData([
                "session": NSNull()
            ])
        }
        try await db.collection("sessions").document(id).delete()
    }
    
    func joinSession(id: String) async throws -> Session {
        let user = UserManager.shared.user
        var session = try await getSession(id: id)
        var members = session.members
        members.append(user)
        try await db.collection("sessions").document(id).updateData([
            "members": members.map { ["name": $0.name, "id": $0.id]},
            "updatedAt": Date().timeIntervalSince1970
        ])
        try await db.collection("users").document(user.id).updateData([
            "session": id
        ])
        session.members = members
        return session
    }
    
    func leaveSession(id: String) async throws {
        let userId = UserManager.shared.user.id
        let session = try await getSession(id: id)
        let members = session.members.filter { $0.id != userId }
        
        try await db.collection("sessions").document(id).updateData([
            "members": members.map { ["name": $0.name, "id": $0.id]},
            "updatedAt": Date().timeIntervalSince1970
        ])
        try await db.collection("users").document(userId).updateData([
            "session": NSNull()
        ])
    }
    
    func listenToSession(id: String, completion: @escaping (Session?) -> Void) {
        listener = db.collection("sessions").document(id).addSnapshotListener { snapshot, error in
            guard let document = snapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data(), let session: Session = try? self.decode(data) else {
                completion(nil)
                return
            }
            completion(session)
        }
    }
    
    func stopListeningToSession() {
        listener?.remove()
    }
    
    // ========================================================================
    // MARK: Users
    // ========================================================================
    
    func getUser(id: String) async throws -> User {
        let doc = try await db.collection("users").document(id).getDocument()
        guard let data = doc.data() else { throw ApiError.noData }
        let user: User = try decode(data)
        return user
    }
    
    func createUser(id: String) async throws -> User {
        try await db.collection("users").document(id).setData([
            "id":id
        ])
        return try await getUser(id: id)
    }
    
    func updateUser(id: String, name: String) async throws {
        try await db.collection("users").document(id).updateData([
            "name": name
        ])
        
        if let sessionId = UserManager.shared.user.session {
            let session = try await getSession(id: sessionId)
            let members: [User] = session.members.map {
                if $0.id == id {
                    return User(id: $0.id, name: name)
                }
                return $0
            }
            try await db.collection("sessions").document(sessionId).updateData([
                "members": members.map { ["name": $0.name, "id": $0.id]}
            ])
        }
    }
    
    // ========================================================================
    // MARK: Spotify
    // ========================================================================
    
    
    func authoriseWithSpotify(code: String) async throws {
        let userId = UserManager.shared.user.id
        let result = try await functions.httpsCallable("authoriseSpotify").call(["code": code, "userId": userId])
        if let result = result.data as? Bool, !result {
            throw ApiError.spotifyAuthoriseFailed
        }
    }
    
    func logoutFromSpotify() async throws {
        let userId = UserManager.shared.user.id
        try await db.collection("users").document(userId).updateData([
            "accessToken": NSNull(),
            "refreshToken": NSNull(),
            "expiresAt": NSNull()
        ])
    }
    
    func searchSpotify(for query: String) async throws -> [Song] {
        let result = try await functions.httpsCallable("searchSpotify").call(["query": query])
        guard let data = result.data as? [[String: Any]] else {
            throw ApiError.failedToDecodeResponse
        }
        return try data.compactMap { try decode($0) }
    }
    
    func addSongToQueue(_ song: Song, sessionId: String) async throws {
        let songDict = [
            "id": song.id,
            "name": song.name,
            "artist": song.artist,
            "album": song.album,
            "imageUrl": song.imageUrl
        ]
        let result = try await functions.httpsCallable("addSongToQueue").call(["song": songDict, "sessionId": sessionId])
            
        if let success = result.data as? Bool, !success {
            throw ApiError.spotifyAuthoriseFailed
        }
    }
    
    func checkCurrentlyPlaying(id: String) async throws {
        try await functions.httpsCallable("checkCurrentlyPlaying").call(["sessionId": id])
    }
    
    // ========================================================================
    // MARK: Apple Music
    // ========================================================================
    
    func getDeveloperToken(sessionId: String) async throws {
        let result = try await functions.httpsCallable("appleMusicDeveloperToken").call(["sessionId": sessionId])
        
        if let success = result.data as? Bool, !success {
            throw ApiError.spotifyAuthoriseFailed
        }
    }
    // ========================================================================
    // MARK: Helper
    // ========================================================================
    
    private func decode<T: Decodable>(_ json: [String:Any]) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: json)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let decoded = try decoder.decode(T.self, from: data)
        return decoded
    }
}

enum ApiError: Error {
    case noData
    case failedToDecodeResponse
    case unknownError
    case spotifyAuthoriseFailed
}
