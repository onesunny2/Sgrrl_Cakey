//
//  NoticeCelll.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/7/24.
//

import SwiftUI

struct NoticeCelll: View {
    @State var notice1: String = ""
    @State var notice2: String = ""

    var body: some View {
        VStack(spacing: 10) {
            Text("\(notice1)")
                .customStyledFont(font: .cakeyHeadline, color: .cakeyOrange1)
            
            Text("\(notice2)")
                .customStyledFont(font: .cakeyCallout, color: .cakeyOrange1)
        }
    }
}

#Preview {
    ZStack {
        Color.cakeyYellow1
            .ignoresSafeArea(.all)
        
        NoticeCelll(notice1: "어떤 색상을 원하세요?", notice2: "원하는 케이크 색상을 선택해 주세요")
    }
}
