//
//  VerticalSlider.swift
//  Cakey
//
//  Created by dora on 11/11/24.
//

import SwiftUI

//세로 슬라이더
struct VerticalSlider: View {
    @Binding var value: Float
    var range: ClosedRange<Float>
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer(minLength: 0)
                Rectangle()
                    .fill(.cakeyOrange1)
                    .frame(height: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.height)
                    .cornerRadius(5)
            }
            .frame(width: geometry.size.width)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(5)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let sliderHeight = geometry.size.height
                        let dragY = max(0, min(sliderHeight, sliderHeight - gesture.location.y))
                        let newValue = Float(dragY / sliderHeight) * (range.upperBound - range.lowerBound) + range.lowerBound
                        value = newValue
                    }
            )
        }
    }
}

