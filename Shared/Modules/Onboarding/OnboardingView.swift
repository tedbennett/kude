//
//  OnboardingView.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 13/01/2022.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var present: Bool
    
    var body: some View {
        VStack {
            
            Text("Welcome to")
                .font(Font.system(size: 35, weight: .bold, design: .rounded))
                .padding(.top, 20)
            Text("Kude")
                .font(Font.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundColor(.accentColor)
            Spacer()
            
//            TabView {
                infoView
//                Text("Second")
//            }.tabViewStyle(.page)
            Spacer()
            Button {
                present.toggle()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                ZStack {
                    HStack {
                        Spacer()
                        Text("Done")
                            .font(.system(.title3, design: .rounded).bold())
                            .foregroundColor(.white)
                        Spacer()
                    }
//                    HStack {
//                        Spacer()
//
//                        Image(systemName: "chevron.right")
//                            .font(.system(.title3, design: .rounded))
//                            .foregroundColor(.white)
//
//                    }
                }
                
                .padding()
                .background(Color.purple)
                .cornerRadius(15)
                .padding()
            }
            .padding(.bottom, 20)
        }.onAppear {
            UserDefaults.standard.setValue(APP_VERSION, forKey: "APP_VERSION")
        }
    }
    
    var infoView: some View {
        VStack(alignment: .leading, spacing: 30) {
            HStack(spacing: 10) {
                ZStack {
                    Image(systemName: "circle").font(Font.system(size: 40)).foregroundColor(.accentColor)
                    Image(systemName: "music.note").font(Font.system(size: 25)).foregroundColor(.accentColor)
                }
                .frame(width: 47, height: 47)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Collaborative queues").fontWeight(.medium)
                    Text("Let your friends add songs your device's music queue").font(.callout).foregroundColor(.gray)
                }
            }
            HStack(spacing: 10) {
                Image("spotify")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.accentColor)
                    .frame(width: 47, height: 47)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Add any song from Spotify").fontWeight(.medium)
                    Text("Only the host needs a premium account.").font(.callout).foregroundColor(.gray)
                }
            }
            HStack(spacing: 10) {
                Image(systemName: "square.stack.3d.up").font(Font.system(size: 40)).foregroundColor(.accentColor)
                    .frame(width: 47, height: 47)
                VStack(alignment: .leading, spacing: 5) {
                    Text("See what's coming next").fontWeight(.medium)
                    Text("See what everyone in the session has added to the queue").font(.callout).foregroundColor(.gray)
                }
            }
            HStack(spacing: 10) {
                Image(systemName: "person.badge.plus").font(Font.system(size: 40)).foregroundColor(.accentColor)
                    .frame(width: 47, height: 47)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Invite others").fontWeight(.medium)
                    Text("Joining a session is as easy as opening a link or copying a key").font(.callout).foregroundColor(.gray)
                }
            }
        }.padding(.horizontal, 10)
    }
    
    var instructionsView: some View {
        VStack(spacing: 30) {
            HStack(spacing: 10) {
                ZStack {
                    Image(systemName: "circle").font(Font.system(size: 40)).foregroundColor(.accentColor)
                    Image(systemName: "music.note").font(Font.system(size: 25)).foregroundColor(.accentColor)
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text("Creating a session").fontWeight(.medium)
                    Text("Click the \"+\" button to create a session").font(.callout).foregroundColor(.gray)
                }
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(present: .constant(true)).previewDevice("iPhone 13").preferredColorScheme(.light).accentColor(.purple)
    }
}
