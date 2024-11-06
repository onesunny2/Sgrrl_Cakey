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
            
            Text("케이크 이미지와 키워드 추가하는 뷰 입니다.")
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
        }
    }
}

#Preview {
    CakeImageView(value: 3, path: .constant([3]))
}
