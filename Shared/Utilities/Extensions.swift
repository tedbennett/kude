//
//  Extensions.swift
//  kude (iOS)
//
//  Created by Ted Bennett on 21/12/2021.
//

import SwiftUI

extension View {
    @ViewBuilder
    func center ( _ axis: Axis)-> some View {
        switch axis {
            case .horizontal:
                HStack {
                    Spacer()
                    self
                    Spacer()
                }
            case .vertical:
                VStack {
                    Spacer()
                    self
                    Spacer()
                }
        }
    }
}
