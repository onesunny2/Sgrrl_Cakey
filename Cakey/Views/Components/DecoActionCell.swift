//
//  DecoActionCell.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/10/24.
//

import SwiftUI

struct DecoActionCell: View {
    var buttonColor: Color = .cakeyOrange3
    var symbolName: String = "arrow.trianglehead.2.clockwise.rotate.90"
    var buttonAction: () -> Void = { }
    
    var body: some View {
        Button {
            buttonAction()
        } label: {
            RoundedRectangle(cornerRadius: 12)
                .fill(buttonColor)
                .frame(width: 88, height: 54)
                .overlay {
                    Image(systemName: symbolName)
                        .font(.symbolTitle1)
                        .foregroundStyle(.cakeyYellow1)
                }
        }
    }
}

#Preview {
    ZStack {
        Color.cakeyYellow1
            .ignoresSafeArea(.all)
        
        DecoActionCell()
    }
}
