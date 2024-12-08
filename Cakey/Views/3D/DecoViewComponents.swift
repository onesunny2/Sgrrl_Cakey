//
//  DecoViewComponents.swift
//  Cakey
//
//  Created by dora on 11/25/24.
//

import SwiftUI

// MARK: - ImageScrollView
@ViewBuilder
func ImageScrollView(imgList: [decoElements], action: @escaping (Data) -> Void) -> some View {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
            // imgList가 비어있거나 이미지가 없는 경우 기본 Placeholder UI 표시
            if imgList.isEmpty || imgList.allSatisfy({ $0.image == nil }) {
                ForEach(0..<6) { _ in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.cakeyOrange2)
                        .frame(width: 80, height: 80)
                        .overlay {
                            Image(systemName: "photo")
                                .font(.symbolTitle2)
                                .foregroundStyle(.cakeyOrange3)
                        }
                }
            } else {
                // imgList에 이미지가 있는 경우 표시
                ForEach(imgList, id: \.self) { decoElement in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.clear)
                        .frame(width: 80, height: 80)
                        .overlay {
                            ZStack {
                                if let imgData = decoElement.image, let uiImage = UIImage(data: imgData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.cakeyOrange1, lineWidth: 2)
                                        .padding(1)
                                } else {
                                    // 이미지 데이터가 없는 경우 기본 Placeholder UI
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.cakeyOrange2)
                                        .frame(width: 80, height: 80)
                                        .overlay {
                                            Image(systemName: "photo")
                                                .font(.symbolTitle2)
                                                .foregroundStyle(.cakeyOrange3)
                                        }
                                }
                            }
                        }
                        // 이미지 클릭 시 액션 호출
                        .onTapGesture {
                            if let imgData = decoElement.image {
                                action(imgData)
                            }
                        }
                }
            }
        }
        .padding(.trailing, 23)
    }
}


// MARK: - ModeSelectView
@ViewBuilder
func ModeSelectView(activeMode: Binding<EditMode>, action: @escaping (EditMode) -> Void) -> some View {
    VStack {
        HStack(spacing: 30) {
            if activeMode.wrappedValue == .editMode {
                Circle()
                    .fill(.cakeyOrange1)
                    .frame(width: 8)
                    .offset(x: -45)
                    .transition(.opacity)
            } else if activeMode.wrappedValue == .lookMode {
                Circle()
                    .fill(.cakeyOrange1)
                    .frame(width: 8)
                    .offset(x: +45)
                    .transition(.opacity)
            }
        }
        
        HStack(spacing: 30) {
            Button(action: {
                action(.editMode)
            }) {
                VStack {
                    Image(systemName: "slider.horizontal.3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(activeMode.wrappedValue == .editMode ? .cakeyOrange1 : .gray)
                    Text("수정하기")
                        .foregroundColor(activeMode.wrappedValue == .editMode ? .cakeyOrange1 : .gray)
                }
            }
            
            Button(action: {
                action(.lookMode)
            }) {
                VStack {
                    Image(systemName: "eye")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(activeMode.wrappedValue == .lookMode ? .cakeyOrange1 : .gray)
                    Text("살펴보기")
                        .foregroundColor(activeMode.wrappedValue == .lookMode ? .cakeyOrange1 : .gray)
                }
            }
        }
    }
}
