//
//  SongSearchView.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 11/01/2022.
//

import SwiftUI

struct SongSearchView: View {
    @Binding var present: Bool
    var completion: (Song) -> Void
    
    @StateObject var viewModel = SongSearchViewModel()
    @State var isEditing = false
    
    var body: some View {
        NavigationView {
            VStack {
                DebouncedTextField(placeholder: "Search for songs", debouncedText: $viewModel.searchText)                
                    .padding(7)
                    .background(RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray5)))
                    .cornerRadius(8)
                    .padding(.horizontal, 10)
                List {
                    ForEach(viewModel.songs) { song in
                        Button() {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                self.present.toggle()
                            }
                            completion(song)
                        } label: {
                            HStack {
                                SongCellView(song: song)
                            }
                        }
                    }
                }.listStyle(PlainListStyle())
            }
            .navigationTitle("Search")
            .navigationBarItems(trailing: Button {
                present.toggle()
            } label: {
                Text("Done")
            })
        }
    }
}

struct SongSearchView_Previews: PreviewProvider {
    static var previews: some View {
        SongSearchView(present: .constant(true)) {_ in}
        .preferredColorScheme(.dark)
    }
}



struct DebouncedTextField : View {
    var placeholder: String
    @Binding var debouncedText : String
    @StateObject private var textObserver = TextFieldObserver()
    
    var body: some View {
        TextField(placeholder, text: $textObserver.searchText)
            .onReceive(textObserver.$debouncedText) { (val) in
                debouncedText = val
            }
    }
}
