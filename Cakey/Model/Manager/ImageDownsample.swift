//
//  ImageDownsampleManager.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/24/24.
//

import SwiftUI

enum ImageDownsample {
    static func downsample(data: Data, to size: CGSize) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
                return nil
            }
            
        let maxDimension = max(size.width, size.height) * UITraitCollection.current.displayScale
        let downsampleOptions = [
          kCGImageSourceCreateThumbnailFromImageAlways: true,
          kCGImageSourceShouldCacheImmediately: true,
          kCGImageSourceCreateThumbnailWithTransform: true,
          kCGImageSourceThumbnailMaxPixelSize: maxDimension
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }

        return UIImage(cgImage: downsampledImage)
    }
}

