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
            self.user = User(id: id)
            FirebaseManager.shared.createUser(id: id) { _ in }
            self.saveUser()
        }
    }
    
    var user: User
    
    func checkSession(completion: @escaping (Session?) -> Void) {
        if let session = user.session {
            FirebaseManager.shared.getSession(id: session) {
                completion($0)
                
            }
        } else {
            completion(nil)
        }
    }
    
    func saveUser() {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "user")
        }
    }
    
    func updateUser(name: String, completion: @escaping (Bool) -> Void) {
        FirebaseManager.shared.updateUser(name: name) { success in
            if success {
                DispatchQueue.main.async {
                    self.user.name = name
                    self.saveUser()
                }
            }
            completion(success)
        }
    }
    
    func addUserToSession(id: String, host: Bool = false) {
        user.session = id
        saveUser()
    }
    
    func removeUserFromSession() {
        user.session = nil
        saveUser()
    }
    
    func authoriseWithSpotify(code: String) {
        FirebaseManager.shared.authoriseWithSpotify(code: code) { success in
            DispatchQueue.main.async {
                self.user.host = success
                self.saveUser()
            }
        }
    }
    
    func logoutFromSpotify() {
        FirebaseManager.shared.logoutFromSpotify() { success in
            DispatchQueue.main.async {
                self.user.host = !success
                self.saveUser()
            }
        }
    }
}
