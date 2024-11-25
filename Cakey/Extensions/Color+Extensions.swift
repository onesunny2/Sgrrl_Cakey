//
//  Color+Extensions.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/18/24.
//

import SwiftUI

extension Color {
    func toHex() -> String? {
        // UIColor로 변환
        let uiColor = UIColor(self)
        
        // UIColor의 구성 요소 가져오기
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        // RGB 값을 0~255 범위로 변환
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        
        // Hex 문자열 생성
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
