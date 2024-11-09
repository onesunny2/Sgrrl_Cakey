//
//  CakeImageView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/7/24.
//

import SwiftUI

struct CakeImageView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let value: Int
    @Binding var path: [Int]
    
    var body: some View {
        ZStack {
            Color.cakeyYellow1
                .ignoresSafeArea(.all)
            
            ProgressBarCell(currentStep: 2)
            
            VStack(spacing: 0) {
                NoticeCelll(notice1: "원하는 데코가 있나요?", notice2: "최대  6개까지 추가할 수 있어요")
                    .padding(.bottom, 54)
                
                DecoCarouselCell()
                
                Spacer()
                
                NextButtonCell(nextValue: {path.append(4)})
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
                    // TODO: 스킵 기능 구현 필요
                } label: {
                    Text("SKIP")
                        .customStyledFont(font: .cakeyCallout, color: .cakeyOrange1)
                }

            }
        }
    }
}

#Preview {
    CakeImageView(value: 3, path: .constant([3]))
}
