//
//  DecoViewOnboardingView.swift
//  Cakey
//
//  Created by dora on 11/28/24.
//

import SwiftUI

struct DecoOnboardingView: View {
    @Binding var isVisible: Bool
    @State private var currentStep: Int = 0

    var body: some View {
        if isVisible {
            ZStack {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            isVisible = false
                        }) {
                            Image(systemName: "multiply")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 23)
                                .foregroundStyle(.cakeyOrange3)
                        }
                        .padding()
                    }
                    
                    Spacer().frame(height: 100)
                    
                    ZStack {
                        // MARK: 1. GestureExplain
                        VStack(spacing: 20) {
                            Image(systemName: "hand.tap")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 58)
                                .foregroundStyle(.cakeyOrange3)
                            Text("이미지를 확대/축소하고,\n꾹 눌러 삭제해 보세요")
                                .font(.cakeyBody)
                                .foregroundStyle(.cakeyOrange3)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.bottom, 100)
                        .opacity(currentStep >= 1 ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5), value: currentStep)
                        
                        // MARK: 2. SliderExplain
                        HStack {
                            VStack(spacing: 20) {
                                Spacer()
                                Text("슬라이더를 위,아래로 움직여서\n여러 각도에서 케이크를 살펴보세요")
                                    .font(.cakeyBody)
                                    .foregroundStyle(.cakeyOrange3)
                                    .multilineTextAlignment(.center)
                            }
                            Image("DecoSlider")
                        }
                        .frame(height: 231)
                        .opacity(currentStep >= 2 ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5), value: currentStep)
                    }
                    
                    Spacer().frame(height: 100)
                    
                    // MARK: 3. PhotoCellExplain
                    VStack(spacing: 20) {
                        Image("DecoCell")
                        Text("이미지를 선택해 자유롭게\n케이크에 배치해 보세요")
                            .font(.cakeyBody)
                            .foregroundStyle(.cakeyOrange3)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(currentStep >= 3 ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5), value: currentStep)
                }
            }
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                    // 1번 카드: 0.5초 뒤
                    currentStep += 1
                    Timer.scheduledTimer(withTimeInterval: 1.8, repeats: true) { timer in
                        // 2,3번 카드: 1.8초 씩 텀 주기
                        if currentStep < 3 {
                            currentStep += 1
                        } else {
                            timer.invalidate()
                        }
                    }
                }
            }
        }
    }
}
