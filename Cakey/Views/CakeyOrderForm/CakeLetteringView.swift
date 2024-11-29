//
//  CakeLetteringView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/10/24.
//

import SwiftUI

struct CakeLetteringView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var path: [Destination]
    @State private var selectedColor: Color = .pickerBlack
    @State private var pickerColor: Color = .white
    @State private var selectedColorIndex: Int = 0
    @State private var text: String = ""
    @State private var keyboardHeight: CGFloat = 0
    @State private var isKeyboardVisible: Bool = false
    var viewModel: CakeyViewModel
    
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
//                    Rectangle()
//                        .fill(.pink)
//                        .frame(width: 230, height: 230)
                    Cake3DTopView(viewModel: viewModel)
                        .frame(width: 230, height: 230)
                    VStack{
                        Text("\(text)")
                            .customStyledFont(font: .cakeyTitle2, color: selectedColor)
                            .multilineTextAlignment(.center)
                            .kerning(5)
                            .lineSpacing(15)
                    }
                }
                    .padding(.bottom, 30)
                
                
                LetteringColorPickerCell(selectedColor: $selectedColor, pickerColor: $pickerColor, selectedColorIndex: $selectedColorIndex)
                    .padding(.bottom, 20)
                
                TextEditorCell(text: $text)
                    .padding(.bottom, isKeyboardVisible ? 155 : 30)
                

                NextButtonCell(nextValue: {
                    path.append(.cakeOrderformView)
                    viewModel.cakeyModel.letteringColor = selectedColor.toHex()
                    viewModel.cakeyModel.letteringText = text
                    viewModel.cakeyModel.saveDate = .now
                    viewModel.cakeyModel.isComplete = true
                }, isButtonActive: false)
            }
            .padding(.top, 86)
            .padding(.bottom, 10)
            
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
                .padding(.bottom, keyboardHeight)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.cakeyModel.letteringColor = "#000000" // default 검정색
                    viewModel.cakeyModel.letteringText = ""
                    
                } label: {
                    Text("SKIP")
                        .customStyledFont(font: .cakeyCallout, color: .cakeyOrange1)
                }
                .padding(.bottom, keyboardHeight)
            }
        }
        .onTapGesture {
            hideKeyboard()  // 화면 터치하면 키보드 내려가게
        }
        .onAppear {
            // 키보드 높이 감지
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    withAnimation {
                        isKeyboardVisible = true
                        self.keyboardHeight = keyboardFrame.height
                    }
                }
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                withAnimation {
                    isKeyboardVisible = false
                    self.keyboardHeight = 0
                }
            }
        }
        .onDisappear {
            // 옵저버 제거
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
}

//#Preview {
//    CakeLetteringView(value: 5, path: .constant([5]))
//}
