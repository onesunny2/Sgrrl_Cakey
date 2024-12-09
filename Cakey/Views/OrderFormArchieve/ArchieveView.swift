//
//  ArchieveView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/6/24.
//

import SwiftUI

struct ArchieveView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var path: [Destination]
    @Bindable var archieveViewModel = ArchieveViewModel()
    @State var cakeyModelList: [CakeyModel] = []
    
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
                
                if cakeyModelList.isEmpty == true {
                    VStack(spacing: 0) {
                        Image(.blank)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 204)
                        
                        Text("저장된 케이크 도안이 없어요!")
                            .customStyledFont(font: .cakeyBody, color: .cakeyOrange1)
                            .padding(.top, 72)
                        
                        Text("나만의 케이크를 꾸미고")
                            .customStyledFont(font: .cakeyCallout, color: .cakeyOrange1)
                            .padding(.top, 28)
                        
                        Text("3D 케이크 도안을 저장해 보세요")
                            .customStyledFont(font: .cakeyCallout, color: .cakeyOrange1)
                            .padding(.top, 8)
                    }
                    .padding(.top, 140)
                } else {
                    ScrollView {
                        LazyVGrid(columns: archieveColums, spacing: 16) {
                            ForEach(cakeyModelList.indices, id: \.self) { index in
                                ArchieveCell(archieveDate: cakeyModelList[index].saveDate, cakeImage: cakeyModelList[index].cakeArImage ?? Data())
                                    .onTapGesture {
                                        path.append(.archieveDetailView(cakeyModelList[index]))
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                }
                
                Spacer()
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
        .onAppear {
            cakeyModelList =  archieveViewModel.readSortedCakeys()
            print("\(archieveViewModel.readSortedCakeys())")
        }
    }
}

//#Preview {
//    ArchieveView()
//}
