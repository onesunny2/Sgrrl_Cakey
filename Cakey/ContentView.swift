//
//  ContentView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/3/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Cakey")
                .customStyledFont(font: .letteringText, color: .pickerPink)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
