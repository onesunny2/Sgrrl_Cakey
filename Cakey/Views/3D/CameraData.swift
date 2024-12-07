//
//  CameraData.swift
//  Cakey
//
//  Created by dora on 11/14/24.
//

import Foundation

// MARK: CameraMode
enum CameraMode {
    case quarterView
    case topView
    case sideView
    
    // TODO: 여기 값이 너무나 노가다
    var cameraHeight: Float {
        switch self {
        case .quarterView:
            return 1.0
        case .topView:
            return 2.8
        case .sideView:
            return 1.2
        }
    }
}

// MARK: EditMode - 수정모드, 살펴보기모드
enum EditMode{
    case editMode
    case lookMode
}
