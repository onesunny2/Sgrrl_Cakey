//
//  CakeOrderformView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/14/24.
//

import SwiftUI

struct CakeOrderformView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let value: Int
    @Binding var path: [Int]
    
    var body: some View {
        Text("마지막 케이크 오더폼 완료 화면입니다.")
    }
}

#Preview {
    CakeOrderformView(value: 6, path: .constant([6]))
}
