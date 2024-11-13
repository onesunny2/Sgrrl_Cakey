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
    
    var body: some View {
        ZStack {
            Color.cakeyYellow1
                .ignoresSafeArea(.all)
            
            ProgressBarCell(currentStep: 4)
            
            NoticeCelll(notice1: "원하는 문구가 있나요?", notice2: "문구를 적고, 케이크 위에 배치해 보세요")
            
            // TODO: 라미 케이크 자리
            
            
            LetteringColorPickerCell(selectedColor: $selectedColor, pickerColor: $pickerColor, selectedColorIndex: $selectedColorIndex)
            
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
    }
}

//#Preview {
//    CakeLetteringView(value: 5, path: .constant([5]))
//}
