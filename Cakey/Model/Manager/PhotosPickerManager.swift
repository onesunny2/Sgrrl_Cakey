//
//  PhotosPickerManager.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/18/24.
//

import SwiftUI
import PhotosUI


struct PhotosPickerManager {
    
    @MainActor
    static func pickImage() async -> PhotosPickerItem? {
        // State로 안전하게 관리
        @State var pickerResult: PhotosPickerItem?

        return await withCheckedContinuation { continuation in
            // PhotosPicker 설정
            let picker = PhotosPicker(
                "케이크로 장식할 사진 고르기", selection: $pickerResult, // @State로 관리되는 Binding 전달
                matching: .images
            )
                .onChange(of: pickerResult, initial: false) { _, result in
                continuation.resume(returning: result)
            }

            // UIWindowScene에서 적절한 UIWindow 가져오기
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                continuation.resume(returning: nil)
                return
            }

            // UIHostingController를 통해 PhotosPicker 표시
            rootViewController.present(
                UIHostingController(rootView: picker),
                animated: true
            )
        }
    }
}
