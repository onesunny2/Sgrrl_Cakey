//
//  ArchieveView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/6/24.
//

import SwiftUI

struct ArchieveView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ZStack {
            Color.cakeyYellow1
                .ignoresSafeArea(.all)
            
            VStack {
                Text("나의 케이크 도안")
                    .customStyledFont(font: .cakeyTitle1, color: .cakeyOrange1)
                
                ScrollView {
                    ArchieveCell()
                }
            }
            .padding(.top, 28)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.cakeyCallout)
                        .foregroundStyle(.cakeyOrange1)
                }
            }
        }
    }
}

#Preview {
    ArchieveView()
}
