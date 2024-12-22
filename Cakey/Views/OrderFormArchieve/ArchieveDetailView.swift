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
    @State var cakeyModel: CakeyModel
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
            
            // MARK: 케이크 캡처 저장 구현
            Button("케이크만 저장") {
                ARVariables.arView.snapshot(saveToHDR: false) { (image) in
                    let compressedImage = UIImage(data: (image?.pngData())!)
                    UIImageWriteToSavedPhotosAlbum(compressedImage!, nil, nil, nil)
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
        if cakeyModel.cakeImages.isEmpty {
            
        } else {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(cakeyModel.cakeImages.map { $0.description }, id: \.self) { keyword in
                    if keyword != "" {
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
    }
    
    // MARK: 우선은 최선의 방법이라 생각되는 것으로 해뒀습니다...
    // 1: Cake3DFinalView - arView를 띄워야 snapshot 실행가능
    // 2: 0.5초 뒤 snapshot의 리턴값 UIImage를 Data로 변환해 CakeModel.arImage에 저장
    // 3: 기존 arView자리에 같은 크기로 snapshot의 리턴값 UIImage 띄움

    
    @State private var compressedImage: UIImage? = nil
    @State private var showCompressedImage: Bool = false

    
    // 캡처 대상 뷰
    func captureContent() -> some View {
        VStack(spacing: 0) {
            HStack {
                orderformTitle()
                Spacer()
            }
            .padding(.leading, 17)
            .padding(.bottom, 28)
            
            // MARK: 3. 0.5초뒤 snapshot 리턴값으로 뷰 변경!
            if showCompressedImage, let compressedImage = compressedImage {
                Image(uiImage: compressedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .padding(.top, -30)
                    .padding(.bottom, 16)
            // MARK: 1. 초기값 arView 띄움!
            } else {
                Cake3DFinalView(cakeyModel: cakeyModel)
                    .frame(width: 300, height: 300)
                    .padding(.top, -30)
                    .padding(.bottom, 16)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            ARVariables.arView.snapshot(saveToHDR: false) { image in
                                if let image = image, let pngData = image.pngData() {
                                    compressedImage = UIImage(data: pngData)
                                    // MARK: 2. 0.5초뒤 snapshot 리턴값으로 viewModel 저장
                                    cakeyModel.cakeArImage = pngData
                                    showCompressedImage = true
                                } else {
                                    print("이미지 캡처 실패ㅠ")
                                }
                            }
                        }
                    }
            }
            designKeywordLists()
        }
        .background(Color.cakeyYellow1)
    }
    
    func saveButton() -> some View {
        VStack {
            Button {
                self.isShowActionSheet = true
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.cakeyBody)
                        .foregroundStyle(.cakeyYellow1)
                    
                    Text("케이크 도안 저장")
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
