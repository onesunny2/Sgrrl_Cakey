//
//  CakeOrderformView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/14/24.
//

import SwiftUI

struct CakeOrderformView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let value: Int
    @Binding var path: [Int]
    @State var isOnLastPage: Bool = true
    @State var keywords: [String] = ["타이니는 개발을 해", "티나는 원피엠", "이브는 디자인피엠", "도라미는 케이크를 그려", "케이키", "무사출시기원일곱여덟일이삼사오"]
    
    
    var body: some View {
        ZStack {
            Color.cakeyYellow1
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                HStack {
                    orderformTitle()
                    Spacer()
                } .padding(.leading, 17)
                    .padding(.bottom, -20)
                
                imageTabview()  // TODO: 안에 도라미 케이크 삽입 자리 있음
                
                designKeywordLists()
                
                Spacer()
                
                saveButton()
            }
            .padding(.top, 20)
            .padding(.bottom, 10)
        }
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.cakeyOrange1 // 현재 페이지 색상
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.cakeyOrange3 // 나머지 페이지 색상
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
            
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 8) {
                    Button {
                        // TODO: 삭제하기 기능 추가 필요
                    } label: {
                        Image(systemName: "trash")
                            .font(.cakeyCallout)
                            .foregroundStyle(.cakeyOrange1)
                    }
                    .opacity(isOnLastPage ? 0 : 100)

                    
                    Button {
                        path.removeAll() // 홈으로 돌아가기
                    } label: {
                        Image(systemName: "house")
                            .font(.cakeyCallout)
                            .foregroundStyle(.cakeyOrange1)
                    }
                }
            }
        }
    }
    
    func orderformTitle() -> some View {
        VStack(alignment: .leading) {
            Text("나의 케이크")
                .customStyledFont(font: .cakeyTitle1, color: .cakeyOrange1)
            Text("Design")
                .customStyledFont(font: .cakeyLargeTitle, color: .cakeyOrange1)
        }
    }
    
    func imageTabview() -> some View {
        TabView {
            Rectangle()
                .fill(.pickerPink)
                .frame(width: 250, height: 200)
                .overlay {
                    Text("1")
                }
            
            Rectangle()
                .fill(.pickerPink)
                .frame(width: 250, height: 200)
                .overlay {
                    Text("2")
                }
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 300)
    }
    
    @ViewBuilder
    func designKeywordLists() -> some View {
        Text("이런 디자인이 들어갔으면 좋겠어요!")
            .customStyledFont(font: .cakeyBody, color: .cakeyOrange1)
            .padding(.bottom, 18)
        
        // 키워드 리스트
        VStack(alignment: .leading, spacing: 8) {
            ForEach(keywords, id: \.self) { keyword in
                HStack(spacing: 12) {
                    Circle()
                        .fill(.cakeyOrange1)
                        .frame(width: 8, height: 8)
                    
                    Text("\(keyword)")
                        .customStyledFont(font: .cakeyCallout, color: .cakeyOrange1)
                        .frame(width: 235, alignment: .leading)
                }
            }
        }
        .padding(.horizontal, 17)
        .padding(.vertical, 18)
        .background {
            RoundedRectangle(cornerRadius: 40)
                .strokeBorder(Color.cakeyOrange1, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [0.5, 7]))
        }
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 45)
                .stroke(Color.cakeyOrange1, lineWidth: 2)
        }
    }
    
    func saveButton() -> some View {
        VStack {
            Text("주문서를 저장하고, 사장님과 공유해보세요!")
                .customStyledFont(font: .cakeyCaption1, color: .cakeyOrange1)
                .padding(.bottom, 11)
            
            Button {
                
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.cakeyBody)
                        .foregroundStyle(.cakeyYellow1)
                    
                    Text("주문서 저장")
                        .customStyledFont(font: .cakeyBody, color: .cakeyYellow1)
                }
                .padding(.vertical, 13)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.cakeyOrange1)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

//#Preview {
//    CakeOrderformView(value: 6, path: .constant([6]))
//}
