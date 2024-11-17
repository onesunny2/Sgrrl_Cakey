//
//  ArchieveView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/6/24.
//

import SwiftUI

struct ArchieveView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var archieveColums: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        ZStack {
            Color.cakeyYellow1
                .ignoresSafeArea(.all)
            
            VStack(spacing: 13) {
                HStack {
                    Text("나의 케이크 도안")
                        .customStyledFont(font: .cakeyTitle1, color: .cakeyOrange1)
                    Spacer()
                } .padding(.leading, 20)
                
                ScrollView {
                    LazyVGrid(columns: archieveColums, spacing: 16) {
                        ForEach(0..<3) { _ in
                            ArchieveCell()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
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

//#Preview {
//    ArchieveView()
//}
