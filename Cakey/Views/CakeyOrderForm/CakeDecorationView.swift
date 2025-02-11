//
//  CakeDecorationView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/9/24.
//

import SwiftUI

struct CakeDecorationView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var viewModel: CakeyViewModel
    @Binding var path: [Destination]
    
    @StateObject var coordinator_deco = Coordinator_deco()
    @State private var isOnboardingVisible: Bool = true
    @State private var isFirstLaunch: Bool = false
    
    var body: some View {
        ZStack {
            ZStack {
                Color.cakeyYellow1
                    .ignoresSafeArea(.all)
                
                ProgressBarCell(currentStep: 3)
                
                VStack(spacing: 0) {
                    NoticeCelll(notice1: "케이크 도안을 만들어 보세요!", notice2: "이미지를 케이크에 자유롭게 배치할 수 있어요")
                        .padding(.bottom, 40)
                    
                    Spacer()
                }
                .padding(.top, 86)
                .padding(.bottom, 20)
            }
            .onTapGesture {
                hideKeyboard()
            }
            
            Cake3DDecoView(coordinator_deco: coordinator_deco, viewModel: viewModel)
            
            // MARK: Onboarding
            if isOnboardingVisible {
                DecoOnboardingView(isVisible: $isOnboardingVisible)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            checkFirstLaunch()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    _ = CakeStateManager.shared.cakeStack.pop()
                    print("현재 케이크 스택의 개수: \(CakeStateManager.shared.cakeStack.elements.count)")
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.cakeyCallout)
                        .foregroundStyle(.cakeyOrange1)
                }
                .opacity(isOnboardingVisible ? 0 : 1)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isOnboardingVisible = true
                } label: {
                    Image(systemName: "questionmark.circle")
                        .foregroundStyle(.cakeyOrange1)
                }
                .opacity(isOnboardingVisible ? 0 : 1)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    path.append(.cakeLetteringView)
                    //MARK: deco 저장
                    coordinator_deco.saveDecoEntity()
                    
                    guard let topstack = CakeStateManager.shared.cakeStack.top() else { return }
                    
                    CakeStateManager.shared.cakeStack.push(topstack)
                    
                    print("현재 케이크 스택의 개수: \(CakeStateManager.shared.cakeStack.elements.count)")
                } label: {
                    Text("완료")
                        .customStyledFont(font: .cakeyCallout, color: .cakeyOrange1)
                }
                .opacity(isOnboardingVisible ? 0 : 1)
            }
        }
        .animation(.easeInOut, value: isOnboardingVisible)
    }
    
    // MARK: - 앱 처음 실행 여부 체크
    func checkFirstLaunch() {
        if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            isFirstLaunch = false
            isOnboardingVisible = false
        } else {
            isFirstLaunch = true
            isOnboardingVisible = true
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore") // 첫 실행 기록
        }
    }
}

