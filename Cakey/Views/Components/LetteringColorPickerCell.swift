//
//  LetteringColorPickerCell.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/13/24.
//

import SwiftUI

struct LetteringColorPickerCell: View {
    
    let colorList: [Color] = [.pickerBlack, .pickerWhite, .pickerPink, .pickerBlue, .pickerPurple]
    @Binding var selectedColor: Color
    @Binding var pickerColor: Color
    @Binding var selectedColorIndex: Int
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(0..<colorList.count, id: \.self) { index in
                VStack(spacing: 8) {
                    if selectedColorIndex == index {
                        Circle()
                            .fill(.cakeyOrange1)
                            .frame(width: 8)
                    } else {
                        Circle()
                            .fill(.cakeyOrange1).opacity(0)
                            .frame(width: 8)
                    }
                    
                    
                    Circle()
                        .stroke(.cakeyOrange1, lineWidth:4)
                        .fill(colorList[index])
                        .frame(width: 28)
                        .onTapGesture {
                            selectedColor = colorList[index]
                            selectedColorIndex = index
                        }
                }
            }
            
            VStack(spacing: 8) {
                if selectedColorIndex == colorList.count {
                    Circle()
                        .fill(.cakeyOrange1)
                        .frame(width: 8)
                } else {
                    Circle()
                        .fill(.cakeyOrange1).opacity(0)
                        .frame(width: 8)
                }
                
                ColorPicker("", selection: $pickerColor)
                    .labelsHidden()
                    .onChange(of: pickerColor, initial: false) { oldColor, newColor in
                        selectedColor = newColor
                        selectedColorIndex = colorList.count
                    }
            }
        }
    }
}

#Preview {
    LetteringColorPickerCell(selectedColor: .constant(.cakeyOrange1), pickerColor: .constant(.cakeyOrange2), selectedColorIndex: .constant(0))
}
