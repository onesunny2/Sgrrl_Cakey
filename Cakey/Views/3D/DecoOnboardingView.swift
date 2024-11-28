//
//  DecoViewOnboardingView.swift
//  Cakey
//
//  Created by dora on 11/28/24.
//

import SwiftUI

struct DecoOnboardingView: View {
    @State private var currentStep: Int = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        // TODO: 닫기 버튼 동작 추가
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
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
                if currentStep < 3 {
                    currentStep += 1
                } else {
                    timer.invalidate() // 모든 단계가 완료되면 타이머 정지
                }
            }
        }
    }
}

#Preview {
    DecoOnboardingView()
}
