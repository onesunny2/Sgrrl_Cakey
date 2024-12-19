//
//  CakeImageView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/7/24.
//

import SwiftUI

struct CakeImageView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var currentIndex: Int = 0
    @State var decoImages: [decoElements] = Array(repeating: decoElements(image: nil, description: ""), count: 6)
    @Binding var path: [Destination]
    @State private var keyboardHeight: CGFloat = 0
    var viewModel: CakeyViewModel
    
    var body: some View {
        ZStack {
            Color.cakeyYellow1
                .ignoresSafeArea(.all)
            
            ProgressBarCell(currentStep: 2)
            
            VStack(spacing: 0) {
                NoticeCelll(notice1: "원하는 데코가 있나요?", notice2: "최대  6개까지 추가할 수 있어요")
                    .padding(.bottom, 54)
                
                DecoCarouselCell(currentIndex: $currentIndex, decoImages: $decoImages)
                    .padding(.bottom, 60)
                
                TextFieldCell(decoElemets: $decoImages, currentIndex: $currentIndex)
                    .padding(.bottom, keyboardHeight - 200)
                
                Spacer()
                
                NextButtonCell(nextValue: {
                    path.append(.cakeDecorationView);
                    //TODO: 이부분 확인
                    CakeStateManager.shared.cakeStack.push(CakeState())
                    print("현재 케이크 스택의 개수: \(CakeStateManager.shared.cakeStack.elements.count)")
                    
                    viewModel.cakeyModel.cakeImages = decoImages
                }, isButtonActive: decoImages[0].image == nil || decoImages[0].description == "")
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
                    CakeStateManager.shared.cakeStack.push(CakeState())
                    print("현재 케이크 스택의 개수: \(CakeStateManager.shared.cakeStack.elements.count)")
                    viewModel.cakeyModel.cakeImages = []
                    path.append(.cakeDecorationView)
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
                        self.keyboardHeight = keyboardFrame.height
                    }
                }
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                withAnimation {
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
//    CakeImageView(value: 3, path: .constant([3]))
//}
