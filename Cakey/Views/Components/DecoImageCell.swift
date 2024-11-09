//
//  DecoImageCell.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/10/24.
//

import SwiftUI

struct DecoImageCell: View {
    // 임시 데이터
    var imgList: [String] = ["zzamong", "cakeBG"]
    var imgTouchAction: () -> Void = { }
    
    var body: some View {
        HStack {
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
                        }
                    }
                    .onTapGesture {
                        imgTouchAction()
                    }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.cakeyYellow1
            .ignoresSafeArea(.all)
        
        DecoImageCell()
    }
}
