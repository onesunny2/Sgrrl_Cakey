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
    var buttonText: String = "전체삭제"
    var buttonAction: () -> Void = { }
    
    var body: some View {
        Button {
            buttonAction()
        } label: {
            VStack{
                RoundedRectangle(cornerRadius: 12)
                    .fill(buttonColor)
                    .frame(width: 168, height: 44)
                    .overlay {
                        HStack{
                            Image(systemName: symbolName)
                                .font(.symbolTitle1)
                                .foregroundStyle(.cakeyYellow1)
                                .padding(.bottom, 0.5)
                            Text(buttonText)
                                .font(.cakeyCaption1)
                                .foregroundColor(.cakeyYellow2)
                        }
                    }
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
