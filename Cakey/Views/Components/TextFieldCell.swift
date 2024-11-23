//
//  textFieldCell.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/9/24.
//

import SwiftUI

struct TextFieldCell: View {
    @State private var text: String = ""
    @Binding var decoElemets: [decoElements]
    @Binding var currentIndex: Int
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            // MARK: 텍스트 필드
            TextField("예시) 감자를 닮은 햄스터", text: $text)
                .padding(.leading, 14)
                .padding(.vertical, 16.5)
                .background(Color.white)
                .frame(width: 292)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(decoElemets[currentIndex].image == nil)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(decoElemets[currentIndex].image == nil ? .textFieldGray : .cakeyOrange1, lineWidth: 3)
                )
                .onChange(of: text, initial: true) { oldValue, newValue in
                    if newValue.count > 15 {
                        text = String(newValue.prefix(15))
                    }
                    decoElemets[currentIndex].description = newValue
                }
                .onChange(of: currentIndex, initial: false) { oldIndex, newIndex in
                    if decoElemets[currentIndex].description != "" {
                       text = decoElemets[currentIndex].description
                    } else {
                        text = ""
                    }
                }
                
            
            // MARK: 글자 제한 수 카운트
            Text("\(text.count)/15")
                .customStyledFont(font: .cakeyCaption1, color: .cakeyOrange1)
        }
    }
}

//#Preview {
//    ZStack {
//        Color.cakeyYellow1
//            .ignoresSafeArea(.all)
//        
//        TextFieldCell()
//    }
//}
