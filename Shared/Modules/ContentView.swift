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
                HomeView(session: viewModel.session)
                    .navigationTitle(Text("Kude"))
                    .tint(Color(uiColor: .systemPurple))
                    
            }
        }.accentColor(Color(uiColor: .systemPurple))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
