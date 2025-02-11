//
//  CakeColorView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/6/24.
//

import SwiftUI

struct CakeColorView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var path: [Destination]
    @State private var selectedColor: Color = .pickerWhite
    @State private var pickerColor: Color = .white
    @State private var selectedColorIndex: Int = 0
    var viewModel: CakeyViewModel
    
    
    var body: some View {
        ZStack {
            Color.cakeyYellow1
                .ignoresSafeArea(.all)
            
            
            ProgressBarCell(currentStep: 1)
            
            VStack(spacing: 0) {
                NoticeCelll(notice1: "어떤 색상을 원하세요?", notice2: "원하는 케이크 색상을 선택해 주세요")
                    .padding(.bottom, 30)
                
                // MARK: 람지의 3D케이크 자리
                Cake3DColorView(selectedColor: $selectedColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                
                CakeColorPickerCell(selectedColor: $selectedColor, pickerColor: $pickerColor, selectedColorIndex: $selectedColorIndex)
                    .padding(.bottom, 70)
                
                NextButtonCell(nextValue: {path.append(.cakeImageView)
                    viewModel.cakeyModel.cakeColor = selectedColor.toHex()}, isButtonActive: false)
            }
            .padding(.top, 86)
            .padding(.bottom, 10)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    // TODO: 이부분 확인
                    _ = CakeStateManager.shared.cakeStack.pop()
                    print("현재 케이크 스택의 개수: \(CakeStateManager.shared.cakeStack.elements.count)")
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.cakeyCallout)
                        .foregroundStyle(.cakeyOrange1)
                }
            }
        }
    }
}
//
//#Preview {
//    CakeColorView(value: 1, path: .constant([1]))
//}
