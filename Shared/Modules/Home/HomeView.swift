//
//  HomeView.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 01/12/2021.
//

import SwiftUI

struct HomeView: View {
    
    @State private var isKeyFocused = false
    @State private var sessionKey = ""
    
    var body: some View {
        GeometryReader { reader in
            VStack {
                VStack {
                    sectionTitle("Join A Session")
                    Text("You can join a session by entering it's six-digit code, or by opening it's URL")
                        .foregroundColor(.gray)
                        .font(.footnote)
                    
                    SessionKeyView(key: $sessionKey)
                        .center(.vertical)
                    
                }
                VStack {
                    sectionTitle("My Session")
                    Group {
                        Image(systemName: "plus.circle.fill").font(.largeTitle)
                            .padding()
                        Text("Requires a Spotify Premium subscription")
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }.center(.vertical)
                }
            }.ignoresSafeArea(.keyboard)
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
    
    func sessionButton(_ session: Session) -> some View {
        NavigationLink {
            SessionView()
        } label: {
            Text(session.name)
                .font(.system(.title2, design: .rounded).bold())
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
