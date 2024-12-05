//
//  DecoEntities.swift
//  Cakey
//
//  Created by dora on 12/4/24.
//

import Foundation
import RealityKit

// TODO: 여기 저장하기!
class DecoEntities: ObservableObject {
    static let shared = DecoEntities()
    var decoEntities: [DecoEntity] = []
}

struct DecoEntity{
    var image: Data
    var position: SIMD3<Float>
    var scale: SIMD3<Float>
    var orientation: simd_quatf
    var transform: Transform
}
