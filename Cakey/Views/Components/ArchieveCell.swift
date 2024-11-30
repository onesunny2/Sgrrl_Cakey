//
//  ArchieveCell.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/9/24.
//

import SwiftUI

struct ArchieveCell: View {
    var archieveDate: Date
    var cakeImage: Data
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.pickerWhite)
            .shadow(color: .black.opacity(0.15), radius: 9, x: 0, y: 8)
            .frame(width: 166, height: 220)
            .overlay {
                // TODO: 라미 3D 케이크 들어갈 자리(프레임 크기 알아서 변경 필요하면 해줘)
                VStack(spacing: 20) {
                    if let image = UIImage(data: cakeImage) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 132, height: 110)
                    } else {
                        Rectangle()
                            .fill(.cakeyOrange3)
                            .frame(width: 132, height: 110)
                    }
                    
                    Text("\(archiveDateFormatter(from: archieveDate))")
                        .customStyledFont(font: .cakeySubhead, color: .cakeyOrange1)
                }
            }
    }
}

// MARK: 저장 날짜 dateFormatter 함수
func archiveDateFormatter(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy년 MM월"
    return formatter.string(from: date)
}

