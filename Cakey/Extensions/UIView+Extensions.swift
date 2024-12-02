//
//  UIView+Extensions.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/17/24.
//

import UIKit

extension UIView {
    // 스크린 화면 캡쳐 시 사용
    func captureAsImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        return renderer.image { context in
            self.layer.render(in: context.cgContext)
        }
    }
    
    // realm 저장소에 저장하기 위해 사용
    func captureAsImageData() -> Data? {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        let image = renderer.image { context in
            self.layer.render(in: context.cgContext)
        }
        return image.pngData()
    }
}
