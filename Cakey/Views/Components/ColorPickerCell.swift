//
//  ColorPickerCell.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/7/24.
//

import SwiftUI

struct ColorPickerCell: View {
    let colorList: [Color] = [.pickerWhite, .pickerPink, .pickerYellow, .pickerBlue, .pickerPurple]
    @Binding var selectedColor: Color
    @Binding var pickerColor: Color
    @State var selectedColorIndex: Int = 0
    
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
                    .onChange(of: pickerColor, initial: false) { newColor, oldColor in
                        selectedColor = newColor
                        selectedColorIndex = colorList.count
                    }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.cakeyYellow1
            .ignoresSafeArea(.all)
        
        ColorPickerCell(selectedColor: .constant(.pickerWhite), pickerColor: .constant(.white))
    }
}
