//
//  CakeyModel.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/4/24.
//

import Foundation
import RealmSwift
import SwiftUI
import RealityKit

struct CakeEntityModel: Hashable {
    var id: String = UUID().uuidString
    var cakeColor: String?
    var decoEntities: [decoEntity] = []
}

struct decoEntity: Decodable, Encodable, Hashable {
    var image: Data?
    var position: SIMD3<Float>
    var rotation: SIMD3<Float>
    var scale: SIMD3<Float>
}

extension CakeEntityModel: Persistable {
    typealias PersistedObject = CakeEntity
    
    init(persistedObject: CakeEntity){
        let decoder = JSONDecoder()
        
        self.id = persistedObject.id
        self.cakeColor = persistedObject.cakeColor
        self.decoEntities = try! decoder.decode([decoEntity].self, from: persistedObject.decoEntities!)
    }
    
    func persistedObject() -> CakeEntity {
        let encoder = JSONEncoder()
        let cake = CakeEntity()
        
        cake.id = self.id
        cake.cakeColor = self.cakeColor
        cake.decoEntities = try! encoder.encode(self.decoEntities)
        
        return cake
    }
}

class CakeEntity: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var cakeColor: String?
    @Persisted var decoEntities: Data?
}







