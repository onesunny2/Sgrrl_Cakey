//
//  NextButtonCell.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/7/24.
//

import SwiftUI

struct NextButtonCell: View {
    var nextValue: () -> Void
    @State var buttonLabel: String = "다음"
    
    var body: some View {
        Button {
            nextValue()
        } label: {
            Text("\(buttonLabel)")
                .customStyledFont(font: .cakeyBody, color: .cakeyYellow1)
                .padding(.vertical, 13)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.cakeyOrange1)
                }
                .padding(.horizontal, 24)
        }
    }
}

//#Preview {
//    ZStack {
//        Color.cakeyYellow1
//            .ignoresSafeArea(.all)
//        
//        NextButtonCell()
//    }
//}
