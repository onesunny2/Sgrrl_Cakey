//
//  CakeLetteringView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/10/24.
//

import SwiftUI

struct CakeLetteringView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let value: Int
    @Binding var path: [Int]
    @State private var selectedColor: Color = .pickerBlack
    @State private var pickerColor: Color = .white
    @State private var selectedColorIndex: Int = 0
    @State private var text: String = ""
    
    var body: some View {
        ZStack {
            Color.cakeyYellow1
                .ignoresSafeArea(.all)
            
            ProgressBarCell(currentStep: 4)
            
            VStack(spacing: 0) {  
                NoticeCelll(notice1: "원하는 문구가 있나요?", notice2: "문구를 적고, 케이크 위에 배치해 보세요")
                    .padding(.bottom, 38)
                
                
                // TODO: 라미 케이크 자리(크기는 알아서 조정해줘)
                ZStack {
                    Rectangle()
                        .fill(.pink)
                        .frame(width: 250, height: 250)
                    
                    Text("\(text)")
                        .multilineTextAlignment(.center)
                }
                    .padding(.bottom, 30)
                
                
                LetteringColorPickerCell(selectedColor: $selectedColor, pickerColor: $pickerColor, selectedColorIndex: $selectedColorIndex)
                    .padding(.bottom, 20)
                
                TextEditorCell(text: $text)
                    .padding(.bottom, 30)
                
                NextButtonCell(nextValue: {path.append(6)})
            }
            .padding(.top, 86)
            .padding(.bottom, 20)
            
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.cakeyCallout)
                        .foregroundStyle(.cakeyOrange1)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // TODO: 스킵 기능 구현 필요
                } label: {
                    Text("SKIP")
                        .customStyledFont(font: .cakeyCallout, color: .cakeyOrange1)
                }
            }
        }
        .onTapGesture {
            hideKeyboard()  // 화면 터치하면 키보드 내려가게
        }
    }
}

//#Preview {
//    CakeLetteringView(value: 5, path: .constant([5]))
//}
