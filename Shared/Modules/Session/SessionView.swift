//
//  SessionView.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 21/12/2021.
//

import SwiftUI
import AlertToast

struct SessionView: View {
    
    @StateObject var viewModel: SessionViewModel
    @State private var presentSearch = false
    
    
    init(session: Session) {
        _viewModel = StateObject(wrappedValue: SessionViewModel(session: session))

        UITableView.appearance().showsVerticalScrollIndicator = false

    }
    
    var shareButton: some View {
        Button {
            let av = UIActivityViewController(activityItems: [viewModel.session.url], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
    }
    
    
    var copyKeyButton: some View {
        Button {
            UIPasteboard.general.string = viewModel.session.key
            viewModel.copiedKey.toggle()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } label: {
            Image(systemName: "key")
        }
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
                ForEach(viewModel.upcomingQueue) { song in
                    SongCellView(song: song)
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await viewModel.refresh()
        }
        .navigationTitle(viewModel.session.name)
        .navigationBarItems(
            trailing: HStack {
                copyKeyButton
                shareButton
                PresentSettingsView(session: $viewModel.session)
            })
        
        .sheet(isPresented: $presentSearch, content: {
            SongSearchView(present: $presentSearch) {
                viewModel.addSongToQueue($0)
            }
        })
        .toast(isPresenting: $viewModel.addedSongToSession, duration: 1.0) {
            AlertToast(type: .complete(.white), title: "Added to Queue!")
        }
        .toast(isPresenting: $viewModel.addingSongToSession) {
            AlertToast(type: .loading)
        }
        .toast(isPresenting: $viewModel.copiedKey, duration: 0.8) {
            AlertToast(type: .complete(.white), title: "Copied Key!")
        }
        .alert(isPresented: $viewModel.failedToAddSong) {
            Alert(title: Text("Failed to add to queue"), message: Text("No active Spotify session found on the host's account"), dismissButton: .destructive(Text("OK")))
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.refreshSecondsSinceQueue()
        }
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

