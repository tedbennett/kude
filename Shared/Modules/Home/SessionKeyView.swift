//
//  SessionKeyView.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 27/12/2021.
//

import SwiftUI

struct SessionKeyView: View {
    @ObservedObject var viewModel: HomeViewModel
    @FocusState private var focused: Bool
    
    var body: some View {
        VStack {
            Spacer()
            TextField("Enter Key", text: $viewModel.sessionKey)
                .onChange(of: viewModel.sessionKey) { key in
                    onKeyChange(key: viewModel.sessionKey)
                }
                .focused($focused)
                .textFieldStyle(PlainTextFieldStyle())
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            Divider()
                .padding(.horizontal, 80)
            
            switch viewModel.searchState {
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
                    if let _ = viewModel.session {
                        NavigationLink {
                            SessionView()
                        } label: {
                            Text("Join")
                        }
                    }
                    
                    Spacer()
                    
                case .didNotFindSession:
                    Text("Couldn't find session")
                    Spacer()
            }
            
        }.center(.vertical)
    }
    
    func onKeyChange(key: String) {
        viewModel.onKeyChange(key: key)
        if viewModel.sessionKey.count == 6 {
            focused = false
        }
    }
}

struct SessionKeyView_Previews: PreviewProvider {
    static var previews: some View {
        SessionKeyView(viewModel: HomeViewModel())
    }
}
