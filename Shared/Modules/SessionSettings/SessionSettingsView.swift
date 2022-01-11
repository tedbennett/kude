//
//  SessionSettingsView.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 28/12/2021.
//

import SwiftUI

struct SessionSettingsView: View {
    @Binding var session: Session
    @Binding var presented: Bool
    
    @State private var sessionNameText: String
    @State private var userNameText: String
    @State private var delay: Int
    
    init(session: Binding<Session>, presented: Binding<Bool>) {
        self._session = session
        self._presented = presented
        
        _sessionNameText = State<String>(initialValue: session.wrappedValue.name)
        _userNameText = State<String>(initialValue: UserManager.shared.user.name)
        _delay = State<Int>(initialValue: session.wrappedValue.delay)
    }
    
    private var delays = [0, 10, 20, 30, 60, 120, 180, 300, 600]
    func delayString(_ value: Int) -> String {
        switch value {
            case 0: return "No Delay"
            case 1..<60: return "\(value) seconds"
            case 60: return "1 minute"
            case 61...: return "\(value / 60) minutes"
            default: return "Invalid delay"
        }
    }
    
    var isHost: Bool {
        session.host == UserManager.shared.user.id
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Session Name")) {
                    if isHost {
                        TextField("Session Name", text: $sessionNameText)
                    } else {
                        Text(session.name)
                    }
                }
                
                Section(header: Text("Your Display Name")) {
                    TextField("Your Name", text: $userNameText)
                }
                
                Section(header: Text("Settings")) {
                    if isHost {
                        Picker(selection: $delay, label: Text("Queue Delay")) {
                            ForEach(delays, id: \.self) {
                                Text(delayString($0))
                            }
                        }
                    } else {
                        Text(delayString(session.delay))
                    }
                }
                
                Section(header: Text("Members")) {
                    ForEach(session.members) { user in
                        Text(user.name)
                    }
                }
                
                if isHost {
                    Section(footer: Text("Return to the home screen to delete a session").foregroundColor(.red)) { }
                }
                Section(footer: Text("Unfortunately, Spotify queues are local to the device. Kude is unable to read or edit the queue from your device, it can only add music to it.")) { }
               
                
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button {
                if isHost {
                    if delay != session.delay || sessionNameText != session.name {
                        Task {
                            try? await FirebaseManager.shared.updateSession(id: session.id, name: sessionNameText, delay: delay)
                        }
                    }
                }
                
                if userNameText != UserManager.shared.user.name {
                    Task {
                        UserManager.shared.updateUser(name: userNameText)
                    }
                }
                presented.toggle()
            } label: {
                Text("Save")
            })
            
        }
    }
}

struct SessionSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionSettingsView(session: .constant(Session.example), presented: .constant(true))
    }
}
