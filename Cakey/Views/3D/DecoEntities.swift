//
//  DecoEntities.swift
//  Cakey
//
//  Created by dora on 12/4/24.
//

import Foundation
import RealityKit

// MARK: Deco의 연속성을 위한 클래스..
class DecoEntities: ObservableObject {
    static let shared = DecoEntities()
    var decoEntities: [DecoEntity] = []
}

struct DecoEntity{
    var id: UInt64
    var image: Data
    var position: SIMD3<Float>
    var scale: SIMD3<Float>
    var orientation: simd_quatf
}

// TODO: 추가
struct TextEntity{
    var text: String
    var position: SIMD3<Float>
    
}
