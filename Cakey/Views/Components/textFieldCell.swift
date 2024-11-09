//
//  textFieldCell.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/9/24.
//

import SwiftUI

struct textFieldCell: View {
    @State private var text: String = ""
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            // MARK: 텍스트 필드
            TextField("예시) 감자를 닮은 햄스터", text: $text)
                .padding(.leading, 14)
                .padding(.vertical, 16.5)
                .background(Color.white)
                .frame(width: 292)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.cakeyOrange1, lineWidth: 3)
                )
                .onChange(of: text, initial: true) { oldValue, newValue in
                    if newValue.count > 15 {
                        text = String(newValue.prefix(15))
                    }
                }
            
            // MARK: 글자 제한 수 카운트
            Text("\(text.count)/15")
                .customStyledFont(font: .cakeyCaption1, color: .cakeyOrange1)
        }
    }
}

#Preview {
    ZStack {
        Color.cakeyYellow1
            .ignoresSafeArea(.all)
        
        textFieldCell()
    }
}
