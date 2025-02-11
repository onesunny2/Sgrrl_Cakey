//
//  HomeView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/5/24.
//

import SwiftUI

struct HomeView: View {
    @State private var path: [Destination] = []
    @Bindable var viewModel = CakeyViewModel(cakeyModel: CakeyModel())
    
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
                    path.append(.archieveView)
                } label: {
                    Text("도안 불러오기")
                        .customStyledFont(font: .cakeyBody, color: .cakeyYellow1)
                        .padding(.vertical, 13)
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.cakeyOrange3)
                        }
                    
                }
                .navigationDestination(for: Destination.self) { destination in
                    switch destination {
                    case .archieveView:
                        ArchieveView(path: $path)
                    case .cakeColorView:
                        CakeColorView(path: $path, viewModel: viewModel)
                    case .cakeImageView:
                        CakeImageView(path: $path, viewModel: viewModel)
                    case .cakeDecorationView:
                        CakeDecorationView(viewModel: viewModel, path: $path)
                    case .cakeLetteringView:
                        CakeLetteringView(path: $path, viewModel: viewModel)
                    case .cakeOrderformView:
                        CakeOrderformView(path: $path, viewModel: viewModel)
                    case .archieveDetailView(let cakeyModel):
                        ArchieveDetailView(path: $path, cakeyModel: cakeyModel)
                    }
                }
                
                
                Button {
                    path.append(.cakeColorView)
                } label: {
                    Text("도안 만들기")
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
        .padding(.bottom, 10)
    }
}

#Preview {
    HomeView()
}
