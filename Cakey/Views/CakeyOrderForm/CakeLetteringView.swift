//
//  CakeLetteringView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/10/24.
//

import SwiftUI

struct CakeLetteringView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let value: Int
    @Binding var path: [Int]
    
    var body: some View {
        ZStack {
            Color.cakeyYellow1
                .ignoresSafeArea(.all)
            
            Text("케이크 레터링 꾸미는 화면입니다.")
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
    CakeLetteringView(value: 5, path: .constant([5]))
}
