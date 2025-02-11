//
//  CakeOrderformView.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/14/24.
//

import SwiftUI
import Photos

struct CakeOrderformView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var path: [Destination]
    @State var isOnLastPage: Bool = true
    @State var showActionSheet: Bool = false
    var viewModel: CakeyViewModel
    
    var body: some View {
        ZStack {
            Color.cakeyYellow1
                .ignoresSafeArea(.all)
           
                VStack(spacing: 0) {
                    captureContent()  // 캡처 대상 뷰
                    Spacer(minLength: 20)
                    saveButton()  // 캡처에서 제외
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
        }
        //TODO: onAppear 다시 보기
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.cakeyOrange1 // 현재 페이지 색상
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.cakeyOrange3 // 나머지 페이지 색상
            
// MARK: *** 기존 버전 hostingController.view.captureAsImageData() 주석
// viewModel에 cakeIamge 저장하는 부분도 captureContent그리는 부분으로 옮겨뒀습니다!
            
//            let hostingController = UIHostingController(rootView: Cake3DFinalView(viewModel: viewModel))
//            
//             let targetSize = CGSize(width: 300, height: 300) // 캡처 크기 설정
//             hostingController.view.frame = CGRect(origin: .zero, size: targetSize)
//             hostingController.view.backgroundColor = .clear // 배경 설정
//             
//             // UIWindow 가져오기
//             guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                   let window = windowScene.windows.first else {
//                 print("UIWindow를 가져오지 못했습니다.")
//                 return
//             }
//             window.addSubview(hostingController.view) // 캡처를 위해 화면에 추가
//
//             DispatchQueue.main.async {
//                 hostingController.view.layoutIfNeeded()
//                 
//                 // 캡처 수행
//                 if let imageData = hostingController.view.captureAsImageData() {
//                     viewModel.cakeyModel.cakeArImage = imageData // Data로 저장
//                     print("캡처 완료.")
//                 } else {
//                     print("이미지 데이터 캡처에 실패했습니다.")
//                 }
//                 
//                 // 뷰를 화면에서 제거
//                 hostingController.view.removeFromSuperview()
//             }
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.cakeyYellow1, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    print("현재 스택 개수: \(CakeStateManager.shared.cakeStack.count)")
                    _ = CakeStateManager.shared.cakeStack.pop()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.cakeyCallout)
                        .foregroundStyle(.cakeyOrange1)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.updateCakey()
                        path.removeAll() // 홈으로 돌아가기
                        CakeStateManager.shared.cakeStack.elements.removeAll()
                    } label: {
                        Image(systemName: "house")
                            .font(.cakeyCallout)
                            .foregroundStyle(.cakeyOrange1)
                    }
            }
        }
        .confirmationDialog("", isPresented: $showActionSheet) {
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

// MARK: *** 기존 버전 hostingController.view.captureAsImage() 남겨둠!
// 이 버전 주석 풀어도 정상 작동함! 근데 위 함수가 더 예쁘게 프레임 잡힘
                
//                let hostingController = UIHostingController(rootView: captureContent())
//                hostingController.view.backgroundColor = .clear // 배경 투명 설정
//
//                // 캡처할 뷰의 크기 설정
//                let fixedSize = CGSize(width: 300, height: 300)
//                // arCakeView의 정해진 크기 (원래 300, 250)
//                hostingController.view.frame = CGRect(origin: .zero, size: fixedSize)
//
//                // UIWindow 가져오기
//                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                      let window = windowScene.windows.first else {
//                    print("UIWindow를 가져오지 못했습니다.")
//                    return
//                }
//                window.addSubview(hostingController.view) // 화면에 추가 (캡처를 위해)
//
//                DispatchQueue.main.async {
//                    hostingController.view.layoutIfNeeded()
//                    
//                    // 캡처 수행
//                    if let capturedImage = hostingController.view.captureAsImage() {
//                        saveScreenShotToAlbum(capturedImage) // 캡처 이미지 앨범 저장
//                        print("성공적으로 저장되었습니다.")
//                    } else {
//                        print("이미지 캡처에 실패했습니다.")
//                    }
//
//                    // 뷰를 화면에서 제거
//                    hostingController.view.removeFromSuperview()
//                }
            }
        }
    }
    
    @ViewBuilder
    func orderformTitle() -> some View {
        VStack(alignment: .leading) {
            Text("나의 케이크")
                .customStyledFont(font: .cakeyTitle1, color: .cakeyOrange1)
            Text("Design")
                .customStyledFont(font: .cakeyLargeTitle, color: .cakeyOrange1)
        }
    }
    
    @ViewBuilder
    func arCakeView() -> some View {
        Image(.zzamong)
            .resizable()
            .scaledToFill()
            .frame(width: 300, height: 250)
            .background(.clear)
    }
    
    @ViewBuilder
    func designKeywordLists() -> some View {
        Text("이런 디자인이 들어갔으면 좋겠어요!")
            .customStyledFont(font: .cakeyBody, color: .cakeyOrange1)
            .padding(.bottom, 12)
        
        // 키워드 리스트
        if viewModel.cakeyModel.cakeImages.isEmpty {
            
        } else {
            VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.cakeyModel.cakeImages.map { $0.description }, id: \.self) { keyword in
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
                Cake3DFinalView(cakeyModel: viewModel.cakeyModel)
                    .frame(width: 300, height: 300)
                    .padding(.top, -30)
                    .padding(.bottom, 16)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            ARVariables.arView.snapshot(saveToHDR: false) { image in
                                if let image = image, let pngData = image.pngData() {
                                    compressedImage = UIImage(data: pngData)
                                    // MARK: 2. 0.5초뒤 snapshot 리턴값으로 viewModel 저장
                                    viewModel.cakeyModel.cakeArImage = pngData
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
                self.showActionSheet = true
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


