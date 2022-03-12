//
//  SongSearchViewModel.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 11/01/2022.
//

import Combine
import Dispatch

class SongSearchViewModel: ObservableObject {
    @Published var songs = [Song]()
    @Published var searchText = "" {
        didSet {
            if searchText.count > 2 {
                getSongsFromSearch()
            }
        }
    }
    
    func getSongsFromSearch() {
        let encodedSearch = searchText.replacingOccurrences(of: " ", with: "+")
        Task { @MainActor in
            if let results = try? await FirebaseManager.shared.searchSpotify(for: encodedSearch) {
                songs = results
            }
        }
    }
}

class TextFieldObserver : ObservableObject {
    @Published var debouncedText = ""
    @Published var searchText = ""
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
            .sink(receiveValue: { t in
                self.debouncedText = t
            } )
            .store(in: &subscriptions)
    }
}
