//
//  CakeDecorationView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/9/24.
//

import SwiftUI

struct CakeDecorationView: View {
    let value: Int
    @Binding var path: [Int]
    
    var body: some View {
        ZStack {
            Color.cakeyYellow1
                .ignoresSafeArea(.all)
            
            ProgressBarCell(currentStep: 3)
            
            Text("3D 케이크에 요소 배치하는 화면입니다.")
        }
    }
}

#Preview {
    CakeDecorationView(value: 4, path: .constant([4]))
}
