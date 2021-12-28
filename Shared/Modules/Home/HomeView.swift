//
//  HomeView.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 01/12/2021.
//

import SwiftUI
import BetterSafariView

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        VStack {
            VStack {
                sectionTitle("Join A Session")
                    .padding(.vertical, 10)
                Text("You can join a session by entering it's six-digit code, or by opening it's URL")
                    .foregroundColor(.gray)
                    .font(.footnote)
                
                SessionKeyView(viewModel: viewModel)
                    .center(.vertical)
                
            }
            VStack {
                sectionTitle("My Session")
                userSessionView
                    .center(.vertical)
            }
        }.ignoresSafeArea(.keyboard)
        .webAuthenticationSession(
            isPresented: $viewModel.startingWebAuthSession
        ) {
                viewModel.webAuthSession
            }
    }
    
    func sectionTitle(_ title: String) -> some View {
        return HStack {
            Text(title)
                .font(.system(.title2, design: .rounded).bold())
                .padding(.horizontal)
            Spacer()
        }
    }
    
    @ViewBuilder
    var userSessionView: some View {
        if let session = viewModel.session {
            sessionLink(session)
        } else {
            createSessionView
        }
    }
    
    func sessionLink(_ session: Session) -> some View {
        return NavigationLink {
            SessionView()
        } label: {
            Text(session.name)
                .font(.system(.title2, design: .rounded).bold())
        }
    }
    
    var createSessionView: some View {
        return VStack {
            Button {
                viewModel.onCreateSessionButtonPressed()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.primary)
                    .padding()
            }
            if viewModel.isHost {
                HStack {
                    Text("Logged in with Spotify")
                        .foregroundColor(.gray)
                        .font(.footnote)
                    Button {
                        viewModel.logoutSessionButtonPressed()
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            } else {
                Text("Requires a Spotify Premium subscription")
                    .foregroundColor(.gray)
                    .font(.footnote)
            }
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
