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

    // ========================================================================
    // MARK: Sessions
    // ========================================================================
    
    func getSession(id: String) async throws -> Session {
        let doc = try await db.collection("sessions").document(id).getDocument()
        guard let data = doc.data() else { throw ApiError.noData }
        let session: Session = try decode(data)
        return session
    }
    
    func createSession() async throws -> Session {
        let user = UserManager.shared.user
        let id = UUID().uuidString
        try await db.collection("sessions").document(id).setData([
            "id": id,
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
}
