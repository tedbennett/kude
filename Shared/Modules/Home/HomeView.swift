//
//  HomeView.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 01/12/2021.
//

import SwiftUI

struct HomeView: View {
    
    @State private var sessionKey = ""
    @State private var searchState = SessionState.notSearching
    
    
    var body: some View {
        GeometryReader { reader in
            VStack {
                VStack {
                    sectionTitle("Join A Session")
                    Text("You can join a session by entering it's six-digit code, or by opening it's URL")
                        .foregroundColor(.gray)
                        .font(.footnote)
                    
                    joinSessionView
                        .center(.vertical)
                    
                }.frame(height: reader.size.height / 2)
                VStack {
                    sectionTitle("My Session")
                    Group {
                        Image(systemName: "plus.circle.fill").font(.largeTitle)
                            .padding()
                        Text("Requires a Spotify Premium subscription")
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }.center(.vertical)
                }.frame(width: .infinity, height: reader.size.height / 2)
            }
        }
    }
    
    func sectionTitle(_ title: String) -> some View {
        return HStack {
            Text(title)
                .font(
                    .system(.title2, design: .rounded).bold())
                .padding(.horizontal)
            Spacer()
        }
    }
    
    var joinSessionView: some View {
        VStack {
            Spacer()
            TextField("Enter Key", text: $sessionKey)
                .textFieldStyle(PlainTextFieldStyle())
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            Divider()
                .padding(.horizontal, 80)
            
            switch searchState {
                case .notSearching:
                    Spacer()
                case .invalidKey:
                    Text("Key must be 6 characters")
                        .foregroundColor(.red)
                    Spacer()
                case .searching:
                    Spacer()
                    ProgressView()
                    Spacer()
                case .foundSession:
                    Spacer()
                    NavigationLink {
                        SessionView()
                    } label: {
                        
                    }
                    Spacer()
                    
                case .didNotFindSession:
                    Text("Couldn't find session")
                    Spacer()
            }
            
            
            
        }.center(.vertical)
    }
    
    func sessionButton(_ session: Session) -> some View {
        NavigationLink {
            SessionView()
        } label: {
            Text(session.name)
                .font(.system(.title2, design: .rounded).bold())
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
