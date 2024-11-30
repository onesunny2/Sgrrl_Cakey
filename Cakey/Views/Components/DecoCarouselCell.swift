//
//  DecoCarouselCell.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/9/24.
//

import SwiftUI
import Vision
import CoreImage.CIFilterBuiltins

struct DecoCarouselCell: View {
    @Binding var currentIndex: Int
    @State private var isAlbumPresented: Bool = false
    @Binding var decoImages: [decoElements]
    
    private let processingQueue = DispatchQueue(label: "ProcessingQueue")
    
    var body: some View {
        VStack(spacing: 40) {
            // MARK: 캐러샐 가로 스크롤 뷰
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 20) {
                    ForEach(0..<6) { index in
                        GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.cakeyOrange2)
                            .frame(width: 230, height: 230)
                            .overlay {
                                if let image = decoImages[index].image {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.cakeyYellow1)
                                            .frame(width: 226, height: 226)
                                        
                                        Image(uiImage: UIImage(data: image)!)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 200, height: 200)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.clear)
                                            .frame(width: 226, height: 226)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(.cakeyOrange1, lineWidth: 4)
                                            )
                                    }
                                } else {
                                    VStack(spacing: 20) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.symbolLargeTitle)
                                        
                                        HStack(spacing: 5) {
                                            Image(systemName: "photo")
                                            Text("이미지 추가")
                                        }
                                        .font(.cakeySubhead)
                                    }
                                    .foregroundStyle(.cakeyOrange3)
                                }
                            }
                            .scrollTransition(.interactive, axis: .horizontal) { effect, phase in
                                effect
                                    .scaleEffect(phase.isIdentity ? 1 : 0.9)
                            }
                            .onTapGesture {
                                if currentIndex > 0 && decoImages[currentIndex-1].image == nil {
                                    isAlbumPresented = false
                                } else {
                                    isAlbumPresented = true
                                } 
                            }
                            .onAppear {
                                updateCurrentIndex(for: geo, index: index)
                            }
                            .onChange(of: geo.frame(in: .global).minX, initial: true) { _, _ in
                                updateCurrentIndex(for: geo, index: index)
                            }
                        }
                        .frame(width: 230, height: 230) // geometry로 인해 무너지는 프레임 재설정
                    }
                }
                .padding(.horizontal, (UIScreen.main.bounds.width - 230) / 2)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .frame(height: 230)
            
            // MARK: 캐러샐 indicators
            HStack(spacing: 8) {
                ForEach(0..<6) { index in
                    Circle()
                        .fill(currentIndex == index ? .cakeyOrange1 : .cakeyOrange2)
                        .frame(width: 8)
                }
            }
        }
        .sheet(isPresented: $isAlbumPresented) {
            ImagePicker(sourceType: .photoLibrary) { selectedImage in
                if let selectedImage = selectedImage {
                    // 스티커 생성
                    createSticker(for: selectedImage) { stickerImage in
                        if let stickerImage = stickerImage {
                            let targetSize = CGSize(width: 230, height: 230)
                            
                            // 스티커 이미지를 다운샘플링
                            if let imageData = stickerImage.pngData(),
                               let downsampledImage = ImageDownsample.downsample(data: imageData, to: targetSize) {
                                // 다운샘플링된 이미지를 decoImages에 저장
                                decoImages[currentIndex].image = downsampledImage.pngData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 캐러셀 옆으로 넘어갔을 때 감지해주는 함수
    private func updateCurrentIndex(for geo: GeometryProxy, index: Int) {
        let screenWidth = UIScreen.main.bounds.width
        let position = geo.frame(in: .global).midX
        
        // 현재 화면 중앙과 뷰의 위치를 비교하여 가까운 경우 업데이트
        if abs(position - screenWidth / 2) < 115 {
            currentIndex = index
        }
    }
    
    // 스티커 생성 함수
    private func createSticker(for image: UIImage, completion: @escaping (UIImage?) -> Void) {
        guard let inputImage = CIImage(image: image) else {
            print("Failed to create CIImage")
            completion(nil)
            return
        }
        
        processingQueue.async {
            guard let maskImage = subjectMaskImage(from: inputImage) else {
                print("Failed to create mask image")
                completion(nil)
                return
            }
            let outputImage = apply(maskImage: maskImage, to: inputImage)
            let stickerImage = render(ciImage: outputImage)
            
            // 고정 크기로 리사이즈
            let targetSize = CGSize(width: 200, height: 200)
            let resizedSticker = stickerImage.resize(to: targetSize)
            
            DispatchQueue.main.async {
                completion(resizedSticker)
            }
        }
    }
    
    // 마스킹 생성
    private func subjectMaskImage(from inputImage: CIImage) -> CIImage? {
        let handler = VNImageRequestHandler(ciImage: inputImage)
        let request = VNGenerateForegroundInstanceMaskRequest()
        do {
            try handler.perform([request])
        } catch {
            print(error)
            return nil
        }
        guard let result = request.results?.first else {
            print("No observations found")
            return nil
        }
        do {
            let maskPixelBuffer = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
            return CIImage(cvPixelBuffer: maskPixelBuffer)
        } catch {
            print(error)
            return nil
        }
    }

    private func apply(maskImage: CIImage, to inputImage: CIImage) -> CIImage {
        let filter = CIFilter.blendWithMask()
        filter.inputImage = inputImage
        filter.maskImage = maskImage
        filter.backgroundImage = CIImage.empty()
        return filter.outputImage!
    }

    private func render(ciImage: CIImage) -> UIImage {
        guard let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent) else {
            fatalError("Failed to render CGImage")
        }
        return UIImage(cgImage: cgImage)
    }
}


// UIImage 크기 변경을 위한 유틸리티 함수
private extension UIImage {
    func resize(to targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
