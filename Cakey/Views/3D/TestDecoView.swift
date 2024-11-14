//
//  TestDecoView.swift
//  Cakey
//
//  Created by dora on 11/13/24.
//

import SwiftUI

struct TestDecoView: View {
    @StateObject var coordinator2 = Coordinator2()
    
    var body: some View {
        ZStack {
            Color.cakeyYellow1
                .ignoresSafeArea(.all)
            
            ProgressBarCell(currentStep: 3)
            
            VStack(spacing: 0) {
                NoticeCelll(notice1: "케이크 도안을 만들어 보세요!", notice2: "이미지를 케이크에 자유롭게 배치할 수 있어요")
                    .padding(.bottom, 40)
                
                // TODO: 도라미 3D 케이크 들어갈 자리(크기는 알아서 수정해도 돼)
                TestCake3DView()
                
                // MARK: 데코레이션 버튼 3개
                // TODO: 각 버튼별 액션 도라미가 해줘야함
                VStack {
                    HStack(spacing: 14) {
                        DecoActionCell(buttonColor: .cakeyOrange3, symbolName: "arrow.trianglehead.2.clockwise.rotate.90", buttonAction: { })
                        DecoActionCell(buttonColor: .cakeyOrange1, symbolName: "trash", buttonText: "개별삭제",buttonAction: { })
                    } .padding(.bottom, 40)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        DecoImageCell(coordinator: coordinator2)
                    } .padding(.leading, (UIScreen.main.bounds.width - 292) / 2)
                }
            }
            .padding(.top, 86)
            .padding(.bottom, 20)
        }
        .navigationBarBackButtonHidden(true)
        
    }
}

#Preview {
    TestDecoView()
}

