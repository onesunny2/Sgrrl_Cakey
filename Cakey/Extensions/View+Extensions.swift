//
//  View+Extension.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/14/24.
//

import SwiftUI

// 키보드 내리는 액션
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


