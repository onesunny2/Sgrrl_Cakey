//
//  DecoImageCell.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/10/24.
//

import SwiftUI

struct DecoImageCell: View {

    // TODO: 데이터 연결
    var imgList: [String] = ["zzamong", "cakeBG"]
    var imgTouchAction: (String) -> Void = { _ in }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(imgList, id: \.self) { img in
                RoundedRectangle(cornerRadius: 10)
                    .fill(.clear)
                    .frame(width: 80, height: 80)
                    .overlay {
                        ZStack {
                            Image("\(img)")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.cakeyOrange1, lineWidth: 2)
                                .padding(1)
                        }
                    }
                    .onTapGesture {
                        imgTouchAction(img)
                        //coordinator.addDecoEntity(imgName: img)
                    }
            }
            
            ForEach(0..<(5 - imgList.count), id: \.self) { _ in
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
}

#Preview {
    ZStack {
        Color.cakeyYellow1
            .ignoresSafeArea(.all)
        
        DecoImageCell(/*coordinator: Coordinator2()*/) { imgName in
            print("Tapped image name: \(imgName)")
        }
    }
}
