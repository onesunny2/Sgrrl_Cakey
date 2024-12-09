//
//  DecoEntities.swift
//  Cakey
//
//  Created by dora on 12/4/24.
//

import Foundation
import RealityKit
import SwiftUI

// MARK: Deco의 연속성을 위한 클래스..
class DecoEntities: ObservableObject {
    static let shared = DecoEntities()
    var decoEntities: [DecoEntity] = []
    var textEntity = TextEntity()
    
    func clearDeco(){
        decoEntities.removeAll()
        textEntity.text.removeAll()
        textEntity.color = Color.black
        textEntity.position = SIMD3<Float>()
        textEntity.scale =  SIMD3<Float>()
    }
}

struct DecoEntity{
    var id: UInt64
    var image: Data
    var position: SIMD3<Float>
    var scale: SIMD3<Float>
    var orientation: simd_quatf
}

struct TextEntity{
    var text: String = ""
    var color: Color = Color.black
    var position: SIMD3<Float> = SIMD3<Float>()
    var scale: SIMD3<Float> = SIMD3<Float>()
}
