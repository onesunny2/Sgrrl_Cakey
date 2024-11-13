//
//  TextEditorCell.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/13/24.
//

import SwiftUI

struct TextEditorCell: View {
    @State private var text: String = ""
    
    // textEditor 입력받는 부분 padding 조절
    init() {
            UITextView.appearance().textContainerInset =
        UIEdgeInsets(top: 13.5, left: 10, bottom: 0, right: 10)
        }
    
    var body: some View {
        ZStack {
            Color.cakeyYellow1
                .ignoresSafeArea(.all)
            
            VStack(alignment: .trailing, spacing: 6) {
                TextEditor(text: $text)
                    .overlay(alignment: .topLeading) {
                        Text("예시) HAPPY\nBIRTH\nDAY")
                            .customStyledFont(font: .cakeyCallout, color: text.isEmpty ? .textFieldGray : .clear)
                            .padding(.top, 13.5)
                            .padding(.leading, 14.5)
                    }
                    .frame(width: 293, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12).stroke(Color.cakeyOrange1, lineWidth: 3)
                    }
                
                Text("최대 3문단 입력 가능")
                    .customStyledFont(font: .cakeyCaption1, color: .cakeyOrange3)
            }
        }
    }
}

//#Preview {
//    ZStack {
//        Color.cakeyYellow1
//            .ignoresSafeArea(.all)
//        
//        TextEditorCell()
//    }
//}
