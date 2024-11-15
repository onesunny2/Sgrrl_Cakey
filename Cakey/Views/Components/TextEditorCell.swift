//
//  TextEditorCell.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/13/24.
//

import SwiftUI
import Combine

struct TextEditorCell: View {
    @Binding var text: String
    private let lineLimit: Int = 3
    private let characterLimit: Int = 7
    
    // textEditor 입력받는 부분 padding 조절
    init(text: Binding<String>) {
        self._text = text
        
        UITextView.appearance().textContainerInset = UIEdgeInsets(top: 13.5, left: 10, bottom: 0, right: 10)
        }
    
    var body: some View {
        ZStack {
            Color.cakeyYellow1
                .ignoresSafeArea(.all)
            
            VStack(alignment: .trailing, spacing: 6) {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $text)
                        .onReceive(Just(text)) { _ in
                            limitText()
                        }
                        .frame(width: 293, height: 88)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12).stroke(Color.cakeyOrange1, lineWidth: 3)
                        }
                        .background(
                            Button(action: {
                                // 빈 공간을 터치해도 키보드가 올라오도록 설정
                                UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
                            }) {
                                Color.clear
                            }
                        )
                    
                    Text("예시) HAPPY\nBIRTH\nDAY")
                        .customStyledFont(font: .cakeyCallout, color: text.isEmpty ? .textFieldGray : .clear)
                        .padding(.top, 13.5)
                        .padding(.leading, 14.5)
                    
                }

                
                Text("최대 3문단 입력 가능")
                    .customStyledFont(font: .cakeyCaption1, color: .cakeyOrange3)
            }
        }
    }
    
    private func limitText() {
        // 현재 텍스트를 줄 단위로 나눔
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        
        // 최대 줄 수 제한을 적용하며, 각 줄의 글자 수를 제한
        var newText = lines.prefix(lineLimit).map { line in
            String(line.prefix(characterLimit))
        }.joined(separator: "\n")
        
        // 텍스트가 달라졌을 때만 업데이트하여 무한 루프 방지
        if newText != text {
            text = newText
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
