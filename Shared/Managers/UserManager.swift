//
//  UserManager.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 29/11/2021.
//

import Foundation

class UserManager {
    static var shared = UserManager()
    private init() {
        if let savedUser = UserDefaults.standard.object(forKey: "user") as? Data,
           let loadedUser = try? JSONDecoder().decode(User.self, from: savedUser) {
            self.user = loadedUser
        } else {
            let id = UUID().uuidString
            user = User(id: id)
            createUser(id: id)
        }
    }
    
    var user: User
    
    func createUser(id: String) {
        Task {
            do {
                _ = try await FirebaseManager.shared.createUser(id: id)
            } catch {
                print("Failed to create user")
            }
        }
        saveUser()
    }
    
    func checkSession() async -> Session? {
        guard let id = user.session else {
            return nil
        }
        do {
            return try await FirebaseManager.shared.getSession(id: id)
        } catch {
            print("Failed to fetch cached session")
            return nil
        }
    }
    
    func saveUser() {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "user")
        }
    }
    
    func updateUser(name: String) {
        Task {
            do {
                let name = name.trimmingCharacters(in: .whitespaces)
                try await FirebaseManager.shared.updateUser(id: user.id, name: name)
                user.name = name
                saveUser()
            } catch {
                print("Failed to update user")
            }
        }
    }
    
    func createSession() async throws -> Session {
        let session = try await FirebaseManager.shared.createSession()
        addUserToSession(id: session.id, host: true)
        return session
    }
    
    func addUserToSession(id: String, host: Bool = false) {
        user.session = id
        saveUser()
    }
    
    func removeUserFromSession() {
        user.session = nil
        saveUser()
    }
    
    func authoriseWithSpotify(code: String) async -> Bool {
        do {
            try await FirebaseManager.shared.authoriseWithSpotify(code: code)
            user.host = true
            saveUser()
            return true
        } catch {
            print("Failed to authorise spotify")
            return false
        }
    }
    
    func logoutFromSpotify() {
        Task {
            do {
                try await FirebaseManager.shared.logoutFromSpotify()
                user.host = false
                saveUser()
            } catch {
                print("Failed to logout spotify")
            }
        }
    }
}
