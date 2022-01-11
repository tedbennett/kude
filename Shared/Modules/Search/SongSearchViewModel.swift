//
//  SongSearchViewModel.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 11/01/2022.
//

import SwiftUI

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
