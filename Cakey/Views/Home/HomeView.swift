//
//  HomeView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/5/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Color.cakeyYellow1
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // 케이크 타이틀
                VStack(alignment: .leading) {
                    Text("나만의 특별한")
                    Text("케이크 디자인")
                    Text("Cakey")
                }
                .padding(.top, 40)
                
                Spacer()
                
                // 케이크 이미지
                Image(.cakeBG)
                    .resizable()
                    .scaledToFit()
                    .padding(.bottom, 50)
                
                // 버튼 2개
                HStack(spacing: 7) {
                    Button {
                        
                    } label: {
                            Text("주문서 불러오기")
                                .foregroundStyle(.black)
                                .padding(.vertical, 13)
                                .frame(maxWidth: .infinity)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                }
                                
                    }
                    
                    
                    Button {
                        
                    } label: {
                            Text("주문서 작성하기")
                                .foregroundStyle(.black)
                                .padding(.vertical, 13)
                                .frame(maxWidth: .infinity)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.cakeyOrange1)
                                }
                               
                    }
                    
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 30)
        }
    }
}

#Preview {
    HomeView()
}
