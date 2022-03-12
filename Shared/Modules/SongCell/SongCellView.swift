//
//  SongCellView.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 28/12/2021.
//

import SwiftUI
import CachedAsyncImage

struct SongCellView: View {
    var song: Song
    var body: some View {
        HStack {
            CachedAsyncImage(url: URL(string: song.imageUrl)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }.frame(width:80, height: 80).cornerRadius(10)
            VStack(alignment: .leading, spacing: 0) {
                Text(song.name)
                    .font(.title3)
                    .fontWeight(.heavy)
                    .lineLimit(2)
                    .padding(.bottom, 3)
                Text("\(song.artist) - \(song.album)")
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .lineLimit(2)
                
            }.padding(5)
        }
    }
}

struct SongCellView_Previews: PreviewProvider {
    static var previews: some View {
        SongCellView(song: Song.example)
    }
}
