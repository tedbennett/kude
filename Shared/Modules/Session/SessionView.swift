//
//  SessionView.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 21/12/2021.
//

import SwiftUI

struct SessionView: View {
    
    @StateObject var viewModel: SessionViewModel
    
    init(session: Session) {
        _viewModel = StateObject(wrappedValue: SessionViewModel(session: session))
    }
    
    
    var body: some View {
        List {
            Section(header: HStack {
                Image(systemName: "square.stack.3d.up")
                Text("Queue")
            }) {
                ForEach(viewModel.session.queue) { song in
                    SongCellView(song: song)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(viewModel.session.name)
        .navigationBarItems(
            trailing: HStack {
                Button {
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                PresentSettingsView()
            })
    }
}

struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView(session: Session.example)
    }
}

struct PresentSettingsView: View {
    @State private var presentSettings = false
    
    var body: some View {
        Button {
            presentSettings.toggle()
        } label: {
            Image(systemName: "gear")
        }.sheet(isPresented: $presentSettings, content: {
            Text("Settings")
        })
    }
}

