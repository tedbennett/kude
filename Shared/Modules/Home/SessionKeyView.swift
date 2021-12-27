//
//  SessionKeyView.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 27/12/2021.
//

import SwiftUI

struct SessionKeyView: View {
    
    enum SessionState {
        case notSearching
        case invalidKey
        case searching
        case foundSession
        case didNotFindSession
    }
    
    @Binding var key: String
    @State private var searchState = SessionState.notSearching
    @FocusState private var focused: Bool
    
    var body: some View {
        VStack {
            Spacer()
            TextField("Enter Key", text: $key)
                .onChange(of: key) { key in
                    onKeyChange(key: key)
                }
                .focused($focused)
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
                    ProgressView()
                    Spacer()
                case .foundSession:
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
    
    func onKeyChange(key: String) {
        self.key = String(key.uppercased().prefix(6))
        if key.count < 6 {
            searchState = .invalidKey
        }
        if key.count == 6 {
            searchState = .searching
            focused = false
        }
    }
}

struct SessionKeyView_Previews: PreviewProvider {
    static var previews: some View {
        SessionKeyView(key: .constant(""))
    }
}
