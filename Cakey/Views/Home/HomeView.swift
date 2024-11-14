//
//  HomeView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/5/24.
//

import SwiftUI

struct HomeView: View {
    @State private var path: [Int] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.cakeyYellow1
                    .ignoresSafeArea(.all)
                
                cakeyHomeScreenComponents()
            }
        }
    }
    
    // MARK: 케이크 홈화면 components 구성
    func cakeyHomeScreenComponents() -> some View {
        VStack(spacing: 0) {
            // 케이크 타이틀
            HStack {
                VStack(alignment: .leading) {
                    Text("나만의 특별한")
                        .customStyledFont(font: .cakeyTitle1, color: .cakeyOrange1)
                    Text("케이크 디자인")
                        .customStyledFont(font: .cakeyTitle1, color: .cakeyOrange1)
                    Text("Cakey")
                        .customStyledFont(font: .cakeyLargeTitle, color: .cakeyOrange1)
                }
                
                Spacer()
            }
            .padding(.top, 40)
            .padding(.leading, 17)
            
            Spacer()
            
            // 케이크 이미지
            Image(.cakeBG)
                .resizable()
                .scaledToFit()
                .padding(.bottom, 50)
            
            // 버튼 2개
            HStack(spacing: 7) {
                Button {
                    path.append(1)
                } label: {
                    Text("주문서 불러오기")
                        .customStyledFont(font: .cakeyBody, color: .cakeyYellow1)
                        .padding(.vertical, 13)
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.cakeyOrange3)
                        }
                    
                }
                .navigationDestination(for: Int.self) { value in
                    if value == 1 {
                        ArchieveView()
                    } else if value == 2 {
                        CakeColorView(value: value, path: $path)
                    } else if value == 3 {
                        CakeImageView(value: value, path: $path)
                    } else if value == 4 {
                        CakeDecorationView(value: value, path: $path)
                    } else if value == 5 {
                        CakeLetteringView(value: value, path: $path)
                    } else if value == 6 {
                        CakeOrderformView(value: value, path: $path)
                    }
                }
                
                
                Button {
                    path.append(2)
                } label: {
                    Text("주문서 작성하기")
                        .customStyledFont(font: .cakeyBody, color: .cakeyYellow1)
                        .padding(.vertical, 13)
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.cakeyOrange1)
                        }
                    
                }
                
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }
}

#Preview {
    HomeView()
}
