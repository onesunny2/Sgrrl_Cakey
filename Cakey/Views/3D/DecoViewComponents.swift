//
//  DecoViewComponents.swift
//  Cakey
//
//  Created by dora on 11/25/24.
//

import SwiftUI

@ViewBuilder
func ImageScrollView(imgList: [decoElements], action: @escaping (Data) -> Void) -> some View {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
            ForEach(Array(imgList.enumerated()), id: \.offset) { index, element in
                if let imgData = element.image {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.clear)
                        .frame(width: 80, height: 80)
                        .overlay {
                            ZStack {
                                if let uiImage = UIImage(data: imgData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.cakeyOrange1, lineWidth: 2)
                                        .padding(1)
                                } else {
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
                        .onTapGesture {
                            action(imgData) // 이미지 데이터 전달
                        }
                }
            }
        }
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
