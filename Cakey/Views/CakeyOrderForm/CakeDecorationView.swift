//
//  CakeDecorationView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/9/24.
//

// TODO: toolBar 위로 뜨게 해야함!
import SwiftUI

struct CakeDecorationView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var viewModel: CakeyViewModel
    @Binding var path: [Destination]
    
    //@AppStorage("isOnboarding") var isOnboarding: Bool = false
    @State private var isOnboardingVisible: Bool = true
    
    var body: some View {
        ZStack {
            ZStack {
                Color.cakeyYellow1
                    .ignoresSafeArea(.all)
                
                ProgressBarCell(currentStep: 3)
                
                VStack(spacing: 0) {
                    NoticeCelll(notice1: "케이크 도안을 만들어 보세요!", notice2: "이미지를 케이크에 자유롭게 배치할 수 있어요")
                        .padding(.bottom, 40)
                    
                    // 3D DecoView
                    Cake3DDecoView(viewModel: viewModel)
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
                        path.append(.cakeLetteringView)
                        // TODO: 완료 기능 구현 필요(arImage 모델 데이터)
                       
                    } label: {
                        Text("완료")
                            .customStyledFont(font: .cakeyCallout, color: .cakeyOrange1)
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
//            .onAppear {
//                // 첫 접속 시 온보딩 표시
//                if !isOnboarding{
//                    isOnboarding = true // 첫 접속 기록 저장
//                }else{
//                    isOnboardingVisible = false
//                }
//            }
            if isOnboardingVisible {
                DecoOnboardingView(isVisible: $isOnboardingVisible)
                    .zIndex(1)
            }
        }
        .animation(.easeInOut, value: isOnboardingVisible)
    }
}


//#Preview {
//    CakeDecorationView(value: 4, path: .constant([4]))
//}
