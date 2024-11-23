//
//  DecoCarouselCell.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/9/24.
//

import SwiftUI

struct DecoCarouselCell: View {
    @Binding var currentIndex: Int
    @State private var isAlbumPresented: Bool = false
    @Binding var decoImages: [decoElements]
    
    var body: some View {
        VStack(spacing: 40) {
            // MARK: 캐러샐 가로 스크롤 뷰
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 20) {
                    ForEach(0..<6) { index in
                        GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.cakeyOrange2)
                            .frame(width: 230, height: 230)
                            .overlay {
                                if let image = decoImages[index].image {
                                    ZStack {
                                        Image(uiImage: UIImage(data: image)!)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 226, height: 226)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                        // TODO: - 테두리 이상한거 물어보기
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.clear)
                                            .frame(width: 226, height: 226)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(.cakeyOrange1, lineWidth: 4)
                                            )
                                    }
                                } else {
                                    VStack(spacing: 20) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.symbolLargeTitle)
                                        
                                        HStack(spacing: 5) {
                                            Image(systemName: "photo")
                                            Text("이미지 추가")
                                        }
                                        .font(.cakeySubhead)
                                    }
                                    .foregroundStyle(.cakeyOrange3)
                                }
                            }
                            .scrollTransition(.interactive, axis: .horizontal) { effect, phase in
                                effect
                                    .scaleEffect(phase.isIdentity ? 1 : 0.9)
                            }
                            .onTapGesture {
                                isAlbumPresented = true
                            }
                            .onAppear {
                                updateCurrentIndex(for: geo, index: index)
                            }
                            .onChange(of: geo.frame(in: .global).minX, initial: true) { _, _ in
                                updateCurrentIndex(for: geo, index: index)
                            }
                        }
                        .frame(width: 230, height: 230) // geometry로 인해 무너지는 프레임 재설정
                    }
                }
                .padding(.horizontal, (UIScreen.main.bounds.width - 230) / 2)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .frame(height: 230)
            
            // MARK: 캐러샐 indicators
            HStack(spacing: 8) {
                ForEach(0..<6) { index in
                    Circle()
                        .fill(currentIndex == index ? .cakeyOrange1 : .cakeyOrange2)
                        .frame(width: 8)
                }
            }
        }
        .sheet(isPresented: $isAlbumPresented) {
            ImagePicker(sourceType: .photoLibrary) { selectedImage in
                if let selectedImage = selectedImage {
                        decoImages[currentIndex].image = selectedImage.pngData()
                }
            }
        }
    }
    
    // 캐러셀 옆으로 넘어갔을 때 감지해주는 함수
    private func updateCurrentIndex(for geo: GeometryProxy, index: Int) {
        let screenWidth = UIScreen.main.bounds.width
        let position = geo.frame(in: .global).midX
        
        // 현재 화면 중앙과 뷰의 위치를 비교하여 가까운 경우 업데이트
        if abs(position - screenWidth / 2) < 115 {
            currentIndex = index
        }
    }
}

//#Preview {
//    ZStack {
//        Color.cakeyYellow1
//            .ignoresSafeArea(.all)
//        
//        DecoCarouselCell()
//    }
//}
