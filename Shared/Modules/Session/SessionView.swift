//
//  SessionView.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 21/12/2021.
//

import SwiftUI

struct SessionView: View {
    
    @StateObject var viewModel: SessionViewModel
    @State private var presentSearch = false
    
    init(session: Session) {
        _viewModel = StateObject(wrappedValue: SessionViewModel(session: session))
    }
    
    
    var body: some View {
        List {
            QueueSongButton(
                initialProgress: $viewModel.secondsSinceQueue,
                secondsProgressed: $viewModel.secondsProgressed,
                queueDelay: viewModel.session.delay
            ) {
                presentSearch.toggle()
            }
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
                PresentSettingsView(session: $viewModel.session)
            })
        
        .sheet(isPresented: $presentSearch, content: {
            
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
    @Binding var session: Session
    
    var body: some View {
        Button {
            presentSettings.toggle()
        } label: {
            Image(systemName: "gear")
        }.sheet(isPresented: $presentSettings, content: {
            SessionSettingsView(session: $session, presented: $presentSettings)
        })
    }
}

