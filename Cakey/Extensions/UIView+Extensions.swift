//
//  UIView+Extensions.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/17/24.
//

import UIKit

extension UIView {
    func captureAsImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        return renderer.image { context in
            self.layer.render(in: context.cgContext)
        }
    }
}
