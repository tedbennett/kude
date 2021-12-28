//
//  SessionView.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 21/12/2021.
//

import SwiftUI

struct SessionView: View {
    
    @ObservedObject var viewModel: SessionViewModel
    
    init(session: Session) {
        viewModel = SessionViewModel(session: session)
    }
    
    var body: some View {
        Text(viewModel.session.key)
    }
}

struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView(session: Session.example)
    }
}
