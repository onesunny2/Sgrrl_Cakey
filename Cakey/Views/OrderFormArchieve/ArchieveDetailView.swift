//
//  ArchieveDetailView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/17/24.
//

import SwiftUI
import Photos

struct ArchieveDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var path: [Destination]
    @State var isOnLastPage: Bool = true
    @State var isShowActionSheet: Bool = false
    @State var isShowAlert: Bool = false
    var cakeyModel: CakeyModel
    var realmManager = RealmManager.shared
    
    var body: some View {
        ZStack {
            Color.cakeyYellow1
                .ignoresSafeArea(.all)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    captureContent()  // 캡처 대상 뷰
                    
                    Spacer(minLength: 16)
                    
                    saveButton()
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
            }
        }
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.cakeyOrange1 // 현재 페이지 색상
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.cakeyOrange3 // 나머지 페이지 색상
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.cakeyYellow1, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
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
                        isShowAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.cakeyCallout)
                            .foregroundStyle(.cakeyOrange1)
                    }
                    .alert("주문서를 삭제하시겠습니까?", isPresented: $isShowAlert) {
                        Button("취소", role: .cancel) {
                            isShowAlert = false
                        }
                        Button("삭제하기", role: .destructive) {
                            realmManager.deleteCakey(cakeyModel.id)
                            presentationMode.wrappedValue.dismiss()
                        }
                    } message: {
                        Text("작성한 모든 데이터가 삭제됩니다.")
                    }

                    
                    Button {
                        path.removeAll()
                    } label: {
                        Image(systemName: "house")
                            .font(.cakeyCallout)
                            .foregroundStyle(.cakeyOrange1)
                    }
                }
            }
        }
        .confirmationDialog("", isPresented: $isShowActionSheet) {
            Button("취소", role: .cancel) {}
            Button("스크린샷 저장") {
                let hostingController = UIHostingController(rootView: captureContent())
                 let targetSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                 hostingController.view.frame = CGRect(origin: .zero, size: targetSize)
                hostingController.view.backgroundColor = .cakeyYellow1
                 
                 // 현재 화면의 뷰 계층에 추가
                 guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first else {
                     print("Failed to access UIWindow")
                     return
                 }
                 window.addSubview(hostingController.view)

                 // 캡처
                 DispatchQueue.main.async {
                     hostingController.view.layoutIfNeeded()
                     if let capturedImage = hostingController.view.captureAsImage() {
                         saveScreenShotToAlbum(capturedImage)
                         print("Image captured and saved successfully.")
                     } else {
                         print("Failed to capture image.")
                     }

                     // 뷰 계층에서 제거
                     hostingController.view.removeFromSuperview()
                 }
            }
            // TODO: 3D 케이크 자리
            Button("케이크만 저장") { }
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
    
    @ViewBuilder
    func cakeImage() -> some View {
        Image(.zzamong)
            .resizable()
            .scaledToFit()
            .frame(width: 300, height: 250)
    }
    
    @ViewBuilder
    func designKeywordLists() -> some View {
        Text("이런 디자인이 들어갔으면 좋겠어요!")
            .customStyledFont(font: .cakeyBody, color: .cakeyOrange1)
            .padding(.bottom, 28)
        
        // 키워드 리스트
        VStack(alignment: .leading, spacing: 8) {
            ForEach(cakeyModel.cakeImages.map { $0.description }, id: \.self) { keyword in
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
    
    // 캡처 대상 뷰
    func captureContent() -> some View {
        VStack(spacing: 0) {
            HStack {
                orderformTitle()
                Spacer()
            }
            .padding(.leading, 17)
            .padding(.bottom, 28)
            
            cakeImage()
                .padding(.bottom, 16)
            
            designKeywordLists()
        }
        .background(Color.cakeyYellow1)
    }
    
    func saveButton() -> some View {
        VStack {
            Text("주문서를 저장하고, 사장님과 공유해보세요!")
                .customStyledFont(font: .cakeyCaption1, color: .cakeyOrange1)
                .padding(.bottom, 11)
            
            Button {
                self.isShowActionSheet = true
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

func saveScreenShotToAlbum(_ screenShot: UIImage) {
    UIImageWriteToSavedPhotosAlbum(screenShot, nil, nil, nil)
    print("정상적으로 앨범에 저장되었습니다.")
}

//#Preview {
//    ArchieveDetailView()
//}