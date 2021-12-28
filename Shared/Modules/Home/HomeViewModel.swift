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
    
    private let AUTHORISE_SPOTIFY_URL = URL(string: "https://accounts.spotify.com/authorize?client_id=1e6ef0ef377c443e8ebf714b5b77cad7&response_type=code&redirect_uri=kude://oauth-callback/&scope=user-read-private%20user-modify-playback-state%20user-read-recently-played%20user-read-playback-state&show_dialog=true")!
    
    var isHost: Bool {
        UserManager.shared.user.host
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
            UserManager.shared.authoriseWithSpotify(code: code)
        }
    }
    
    func findSession() {
        Task { @MainActor in
            do {
                session = try await FirebaseManager.shared.getSession(key: sessionKey)
                searchState = .foundSession
            } catch {
                session = nil
                searchState = .didNotFindSession
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if self.searchState == .didNotFindSession {
                        withAnimation {
                            self.searchState = .notSearching
                            self.sessionKey = ""
                        }
                    }
                }
            }
        }
    }
    
    
    func onCreateSessionButtonPressed() {
        if isHost {
            Task { @MainActor in
                do {
                    session = try await FirebaseManager.shared.createSession()
                } catch {
                    
                }
            }
        } else {
            startingWebAuthSession.toggle()
        }
    }
    
    func logoutSessionButtonPressed() {
        
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

    enum SessionState {
        case notSearching
        case invalidKey
        case searching
        case foundSession
        case didNotFindSession
    }
}
