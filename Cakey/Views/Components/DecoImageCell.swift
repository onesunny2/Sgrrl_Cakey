//
//  DecoImageCell.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/10/24.
//

import SwiftUI

struct DecoImageCell: View {
    // 임시 데이터
    var imgList: [decoElements]
    var imgTouchAction: () -> Void = { }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(imgList.map{ $0.image }, id: \.self) { img in
                RoundedRectangle(cornerRadius: 10)
                    .fill(.clear)
                    .frame(width: 80, height: 80)
                    .overlay {
                        ZStack {
                            if let img = img, let uiImage = UIImage(data: img) {
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
                        imgTouchAction()
                    }
            }
        }
        .padding(.trailing, (UIScreen.main.bounds.width - 292) / 2)
    }
}

//#Preview {
//    ZStack {
//        Color.cakeyYellow1
//            .ignoresSafeArea(.all)
//        
//        DecoImageCell()
//    }
//}
