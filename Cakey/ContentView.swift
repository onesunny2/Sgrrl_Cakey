//
//  ContentView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/3/24.
//

import SwiftUI

//var id: String = UUID().uuidString
//var cakeColor: String?
//var letteringText: String?
//var letteringColor: String?
//var cakeImages: [decoElements] = []
//var saveDate: Date = .now
//var isComplete: Bool = false

struct ContentView: View {
    @State var cakeyViewModel = CakeyViewModel(cakeyModel: CakeyModel())
    
    var body: some View {
        ZStack {
            VStack {
                if let cakey = cakeyViewModel.readSortedCakeys().first {
                    Text("\(cakey.cakeColor ?? "")")
                    Text("\(cakey.letteringText ?? "")")
                    Text("\(cakey.letteringColor ?? "")")
                    Text("\(cakey.saveDate)")
                    Text("\(cakey.isComplete)")
                }
                
                Text("\(cakeyViewModel.readSortedCakeys()[1].cakeColor ?? "")")
                Text("\(cakeyViewModel.readSortedCakeys()[1].letteringText ?? "")")
                Text("\(cakeyViewModel.readSortedCakeys()[1].letteringColor ?? "")")
                Text("\(cakeyViewModel.readSortedCakeys()[1].saveDate)")
                Text("\(cakeyViewModel.readSortedCakeys()[1].isComplete)")
                
                Button {
                    cakeyViewModel.cakeyModel.cakeColor = "짜몽"
                    cakeyViewModel.cakeyModel.letteringText = "원선"
                    cakeyViewModel.cakeyModel.letteringColor = "기영"
                    cakeyViewModel.cakeyModel.saveDate = .now
                    cakeyViewModel.cakeyModel.isComplete = false
                    cakeyViewModel.updateCakey()
                    cakeyViewModel.readSortedCakeys()
                } label: {
                    Text("cakeyColor")
                }
                
                Button {
                    cakeyViewModel.deleteCakey(key: cakeyViewModel.readSortedCakeys()[1].id)
                } label: {
                    Text("삭제")
                }


            }
                
        }
        .padding()
    }
}

//#Preview {
//    ContentView()
//}
