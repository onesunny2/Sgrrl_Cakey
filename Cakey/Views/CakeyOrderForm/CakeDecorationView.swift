//
//  CakeDecorationView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/9/24.
//

import SwiftUI

struct CakeDecorationView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let value: Int
    @Binding var path: [Int]
    
    
    var body: some View {
        ZStack {
            Color.cakeyYellow1
                .ignoresSafeArea(.all)
            
            ProgressBarCell(currentStep: 3)
            
            VStack(spacing: 0) {
                NoticeCelll(notice1: "케이크 도안을 만들어 보세요!", notice2: "이미지를 케이크에 자유롭게 배치할 수 있어요")
                    .padding(.bottom, 40)
                
                // 3D DecoView
                Cake3DDecoView()
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
                    path.append(5)
                    // TODO: 완료 기능 구현 필요
                } label: {
                    Text("완료")
                        .customStyledFont(font: .cakeyCallout, color: .cakeyOrange1)
                }
            }
        }
    }
}

#Preview {
    CakeDecorationView(value: 4, path: .constant([4]))
}
