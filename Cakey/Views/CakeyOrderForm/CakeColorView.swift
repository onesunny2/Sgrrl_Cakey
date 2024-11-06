//
//  CakeColorView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/6/24.
//

import SwiftUI

struct CakeColorView: View {
    let value: Int
    @Binding var path: [Int]
    
    var body: some View {
        Text("케이크 색상 선택 뷰 입니다.")
    }
}

#Preview {
    CakeColorView(value: 1, path: .constant([1]))
}
