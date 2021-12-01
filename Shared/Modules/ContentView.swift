//
//  ContentView.swift
//  Shared
//
//  Created by Ted Bennett on 28/11/2021.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationView {
            if viewModel.loading {
                ProgressView {
                    Text("Loading...")
                }
            } else {
                Text("HELLO")
//                HomeView()
//                if let session = viewModel.session {
//                    NavigationLink(
//                        destination: SessionView(session: session, inSession: $viewModel.inSession),
//                        isActive: $viewModel.inSession,
//                        label: {
//                            EmptyView()
//                        })
//                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
