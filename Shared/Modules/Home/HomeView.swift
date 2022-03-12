//
//  HomeView.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 01/12/2021.
//

import SwiftUI
import BetterSafariView

struct HomeView: View {
    @ObservedObject private var viewModel: HomeViewModel
    @State private var presentInfo = UserDefaults.standard.integer(forKey: "APP_VERSION") < APP_VERSION
    
    init(session: Session?) {
        viewModel = HomeViewModel(session: session)
    }
    
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
                if viewModel.currentlyHosting {
                    sectionTitle("My Session")
                } else if viewModel.session != nil {
                    sectionTitle("Current Session")
                } else {
                    sectionTitle("Create a Session")
                }
                userSessionView
                    .center(.vertical)
            }
        }.ignoresSafeArea(.keyboard)
            .toolbar {
                Button {
                    presentInfo.toggle()
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        .webAuthenticationSession(
            isPresented: $viewModel.startingWebAuthSession
        ) {
            viewModel.webAuthSession
        }
        .sheet(isPresented: $viewModel.presentSettings, content: {
            settingsSheet
        }).sheet(isPresented: $presentInfo) {
            OnboardingView(present: $presentInfo).accentColor(.purple)
        }
        .onOpenURL { url in
            viewModel.joinSession(from: url)
        }
    }
    
    @ViewBuilder
    var settingsSheet: some View {
        if let session = viewModel.session {
            SessionSettingsView(session: .constant(session), presented: $viewModel.presentSettings)
        } else {
            EmptyView()
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
            VStack {
                sessionLink(session)
                HStack(spacing: 0) {
                    Button {
                        viewModel.presentSettings.toggle()
                    } label: {
                        Spacer()
                        Text("Settings")
                            .font(.system(.title3, design: .rounded).bold())
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    }
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(15)
                    .padding(.leading)
                    .padding(.trailing, 5)
                    if viewModel.currentlyHosting {
                        Button {
                            viewModel.deleteSession()
                        } label: {
                            Spacer()
                            Text("Delete")
                                .font(.system(.title3, design: .rounded).bold())
                                .foregroundColor(.red.opacity(0.8))
                                .padding()
                            Spacer()
                        }
                        .background(Color(uiColor: .systemGray6))
                        .cornerRadius(15)
                        .padding(.leading, 5)
                        .padding(.trailing)
                    } else {
                        Button {
                            viewModel.leaveSession()
                        } label: {
                            Spacer()
                            Text("Leave")
                                .font(.system(.title3, design: .rounded).bold())
                                .foregroundColor(.red.opacity(0.8))
                                .padding()
                            Spacer()
                        }
                        .background(Color(uiColor: .systemGray6))
                        .cornerRadius(15)
                        .padding(.leading, 5)
                        .padding(.trailing)
                    }
                }
            }
        } else {
            createSessionView
        }
    }
    
    func sessionLink(_ session: Session) -> some View {
        ZStack {
            NavigationLink(isActive: $viewModel.presentSessionView) {
                SessionView(session: session)
            } label: {
                EmptyView()
            }
            Button {
                viewModel.sessionKey = ""
                viewModel.searchState = .notSearching
                viewModel.presentSessionView.toggle()
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(session.name)
                            .foregroundColor(.accentColor)
                            .font(.system(.title2, design: .rounded).bold())
                        Text(session.members.count == 1 ? "\(session.members.count) member" : "\(session.members.count) members")
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                    
                }.padding()
                
                    .padding(.vertical)
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(15)
            }
            .padding(.horizontal)
            .buttonStyle(.plain)
        }
    }
    
    var createSessionView: some View {
        return VStack {
            Button {
                viewModel.onCreateSessionButtonPressed()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                    .padding()
            }
            if viewModel.isHost {
                VStack {
                    Text("Logged in with Spotify")
                        .foregroundColor(.gray)
                        .font(.footnote)
                    Button {
                        viewModel.logoutSpotifyButtonPressed()
                    } label: {
                        Text("Logout")
                            .font(.footnote)
                    }
                }
            } else {
                Text("Requires a Spotify Premium subscription")
                    .foregroundColor(.gray)
                    .font(.footnote)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(session: Session.example)
    }
}

