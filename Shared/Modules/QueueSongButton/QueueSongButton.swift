//
//  QueueSongButton.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 11/01/2022.
//

import SwiftUI

struct QueueSongButton: View {
    @Binding var initialProgress: Int
    @Binding var secondsProgressed: Double
    var queueDelay: Int
    var action: () -> Void
    
    
    let timer = Timer
        .publish(every: 0.25, on: .main, in: .common)
        .autoconnect()
    
    var canQueue: Bool {
        return (Double(initialProgress) + secondsProgressed) >= Double(queueDelay)
    }
    
    func progress() -> CGFloat {
        return (CGFloat(Double(initialProgress) + secondsProgressed) / CGFloat(queueDelay))
    }
    
    var time: String {
        let secondsLeft = queueDelay - (initialProgress + Int(secondsProgressed))
        let minutes = secondsLeft / 60
        let seconds = secondsLeft % 60
        
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
    
    var progressView: some View {
        ZStack {
            Circle().trim(from:0, to: progress())
                .stroke(
                    style: StrokeStyle(
                        lineWidth: 5,
                        lineCap: .round,
                        lineJoin:.round
                    )
                )
                .foregroundColor(.gray)
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))
                .onReceive(timer) { _ in
                    withAnimation {
                        secondsProgressed += 0.25
                    }
                }
            Text(time)
                .fontWeight(.heavy)
                .frame(width: 45)
                .foregroundColor(.gray)
                .animation(.none, value: 0)
        }
    }
    
    var body: some View {
        if canQueue {
            Button {
                action()
            } label: {
                HStack {
                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .frame(width:80, height: 80)
                    Text("Add Song to Queue")
                        .font(.title3)
                        .fontWeight(.heavy)
                        .padding()
                }
            }.buttonStyle(PlainButtonStyle())
        } else {
            HStack {
                progressView
                Text("Add Song to Queue")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .padding()
                    .foregroundColor(.gray)
            }.padding(.vertical, 8)
        }
        
    }
}

struct QueueSongButton_Previews: PreviewProvider {
    static var previews: some View {
        QueueSongButton(initialProgress: .constant(80), secondsProgressed: .constant(5), queueDelay: 120, action: {})
    }
}
