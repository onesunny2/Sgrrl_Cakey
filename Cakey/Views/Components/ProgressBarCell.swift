//
//  ProgressBarCell.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/7/24.
//

import SwiftUI

struct ProgressBarCell: View {
    @State var currentStep: Int = 0
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .fill(.cakeyOrange1).opacity(0.3)
                    .frame(maxWidth: .infinity, maxHeight: 4)
                
                HStack(spacing: 0) {
                    ForEach(0..<5) { step in
                        Rectangle()
                            .fill(step < currentStep ? .cakeyOrange1 : .cakeyOrange1.opacity(0))
                            .frame(maxWidth: .infinity, maxHeight: 4)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.top, 2)
    }
}

#Preview {
    ZStack {
        Color.cakeyYellow1
            .ignoresSafeArea(.all)
        
        ProgressBarCell()
    }
}
