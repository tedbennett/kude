//
//  HomeViewModel.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 27/12/2021.
//

import SwiftUI
import BetterSafariView


class HomeViewModel: ObservableObject {
    @Published var sessionKey = ""
    @Published var session: Session?
    @Published var searchState: SessionState = .notSearching
    @Published var startingWebAuthSession = false
    @Published var presentSettings = false
    @Published var isHost = UserManager.shared.user.host
    
    @Published var presentSessionView = false
    
    init(session: Session?) {
        self.session = session
        if session != nil {
            listenToSession()
        }
    }
    
    private let AUTHORISE_SPOTIFY_URL = URL(string: "https://accounts.spotify.com/authorize?client_id=1e6ef0ef377c443e8ebf714b5b77cad7&response_type=code&redirect_uri=kude://oauth-callback/&scope=user-read-private%20user-modify-playback-state%20user-read-recently-played%20user-read-playback-state&show_dialog=true")!
    
    var currentlyHosting: Bool {
        guard let id = session?.host else { return false }
        return UserManager.shared.user.id == id
    }
    
    var webAuthSession: WebAuthenticationSession {
        WebAuthenticationSession(
            url: AUTHORISE_SPOTIFY_URL,
            callbackURLScheme: "kude"
        ) { callbackURL, error in
            guard let callbackURL = callbackURL, error == nil,
                  let url = URLComponents(url: callbackURL, resolvingAgainstBaseURL: true),
                  let code = url.queryItems?.first(where: { $0.name == "code" })?.value else {
                      print(error.debugDescription)
                      return
                  }
            Task { @MainActor in
                self.isHost = await UserManager.shared.authoriseWithSpotify(code: code)
            }
        }
    }
    
    func findSession() {
        Task { @MainActor in
            do {
                let session = try await FirebaseManager.shared.getSession(key: sessionKey)
                searchState = .foundSession(session: session)
            } catch {
                searchState = .didNotFindSession
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    switch self.searchState {
                        case .didNotFindSession:
                            withAnimation {
                                self.searchState = .notSearching
                            }
                        default: break
                    }
                }
            }
        }
    }
    
    func joinSession() {
        switch searchState {
            case .foundSession(let session):
                Task { @MainActor in
                    do {
                        let newSession = try await FirebaseManager.shared.joinSession(id: session.id)
                        UserManager.shared.addUserToSession(id: newSession.id)
                        self.session = newSession
                        listenToSession()
                    } catch {
                        
                    }
                }
            default: return
        }
    }
    
    func onCreateSessionButtonPressed() {
        if isHost {
            Task { @MainActor in
                do {
                    session = try await UserManager.shared.createSession()
                    listenToSession()
                } catch {
                    
                }
            }
        } else {
            startingWebAuthSession.toggle()
        }
    }
    
    func onKeyChange(key: String) {
        let trimmedKey = String(
            key.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
                .uppercased()
                .prefix(6)
        )
        sessionKey = trimmedKey
        withAnimation {
            switch trimmedKey.count {
                case 0:
                    searchState = .notSearching
                case 1..<6:
                    searchState = .invalidKey
                case 6:
                    searchState = .searching
                    findSession()
                default: break
            }
        }
    }
    
    
    func listenToSession() {
        guard let session = session else {
            return
        }
        FirebaseManager.shared.listenToSession(id: session.id) {
            guard let session = $0 else {
                DispatchQueue.main.async {
                    self.presentSessionView = false
                    self.session = nil
                }
                FirebaseManager.shared.stopListeningToSession()
                return
            }
            DispatchQueue.main.async {
                self.session = session
            }
        }
    }
    
    func stopListeningToSession() {
        FirebaseManager.shared.stopListeningToSession()
    }
    
    
    func leaveSession() {
        guard let id = session?.id else {
            return
        }
        Task { @MainActor in
            try? await FirebaseManager.shared.leaveSession(id: id)
            UserManager.shared.removeUserFromSession()
            session = nil
            stopListeningToSession()
        }
    }
    
    func deleteSession() {
        guard let id = session?.id else {
            return
        }
        Task { @MainActor in
            try? await FirebaseManager.shared.deleteSession(id: id)
            UserManager.shared.removeUserFromSession()
            session = nil
            stopListeningToSession()
        }
    }
    
    func joinSession(from url: URL) {
        guard url.host == "www.kude.app" || url.host == "kude.app",
              url.pathComponents.count == 3,
              url.pathComponents[1] == "session" else {
                  return
              }
        Task { @MainActor in
            do {
                let session = try await FirebaseManager.shared.joinSession(id: url.pathComponents[2])
                UserManager.shared.addUserToSession(id: session.id)
                self.session = session
                listenToSession()
            } catch {
                
            }   
        }
        
    }
    
    func logoutSpotifyButtonPressed() {
        UserManager.shared.logoutFromSpotify()
        isHost = false
    }
    
    enum SessionState {
        case notSearching
        case invalidKey
        case searching
        case foundSession(session: Session)
        case didNotFindSession
    }
}
