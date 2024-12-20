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
// TODO: Observable도 없앨 것

class CakeState: ObservableObject {
    //static let shared = CakeState()
    @Published var decoEntities: [DecoEntity] = []
    @Published var textEntity = TextEntity()
    
    // TODO: Stack 관리 이후에 없앨 것
//    func clearDeco(){
//        decoEntities.removeAll()
//        textEntity.text.removeAll()
//        textEntity.color = Color.black
//        textEntity.position = SIMD3<Float>()
//        textEntity.scale =  SIMD3<Float>()
//    }
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

// MARK: Stack 원형
struct Stack<T>{
    var elements: [T] = []
    
    var count : Int {
        return elements.count
    }
    var isEmpty : Bool {
        return elements.isEmpty
    }
    
    func top() -> T? {
        return elements.last
    }
    
    mutating func push(_ element: T) {
        elements.append(element)
    }
    
    mutating func pop() -> T? {
        return elements.popLast()
    }
}

class CakeStateManager: ObservableObject {
    static let shared = CakeStateManager()
    
    @Published var cakeStack :Stack<CakeState> = Stack()
}



// cakeStateManager를 만들어서 그에 따라 초기 상태 불러오도록 해야 한다.
// stack

// 1. color

// 1-A. home -> color
// 1-B. color <- deco : class 비우기

// 2. deco

// 2-A. color -> deco
// 2-B. deco <- lettering : 저장된 deco 불러와야 함

// 3. lettering

// 3-A. deco -> lettering:
// 3-B. lettring ->

// 4. final

// currentStep 숫자랑 연동해야 할 것 같음.
// coordinator도 하나로 통일 할 수 있을 것 같다.
