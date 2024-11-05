//
//  Text+Extensions.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/5/24.
//

import SwiftUI

extension Text {
    func customStyledFont(font: Font, color: Color) -> some View {
        self.font(font)
            .foregroundColor(color)
    }
}
