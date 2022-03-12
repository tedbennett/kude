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
                .font(.system(size: 24, weight: .semibold, design: .rounded))
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
                case .foundSession(let session):
                    Button {
                        viewModel.joinSession()
                        viewModel.presentSessionView.toggle()
                        viewModel.sessionKey = ""
                    } label: {
                        Text("Join")
                            .foregroundColor(.accentColor)
                            .padding()
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(15)
                    }
                    .disabled(viewModel.currentlyHosting)
                    .buttonStyle(.plain)
                    
                    if viewModel.currentlyHosting {
                        Text("Delete your current session before joining")
                    }
                    
                    NavigationLink(
                        isActive: $viewModel.presentSessionView
                    ) {
                        SessionView(session: session)
                    } label: {
                        EmptyView()
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
        SessionKeyView(viewModel: HomeViewModel(session: nil))
    }
}
