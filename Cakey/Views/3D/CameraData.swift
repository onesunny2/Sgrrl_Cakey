//
//  CameraData.swift
//  Cakey
//
//  Created by dora on 11/14/24.
//

import Foundation

enum CameraMode {
    case quarterView
    case topView
    case sideView

    var cameraHeight: Float {
        switch self {
        case .quarterView:
            return 1.0
        case .topView:
            return 2.0
        case .sideView:
            return 0.5
        }
    }
}
