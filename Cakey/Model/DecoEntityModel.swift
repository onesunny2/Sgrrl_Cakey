////
////  CakeyModel.swift
////  Cakey
////
////  Created by Lee Wonsun on 11/4/24.
////
//
//import Foundation
//import RealmSwift
//import SwiftUI
//import RealityKit
//
//struct DecoEntityModel: Hashable {
//    var id: String = UUID().uuidString
//    var decoEntities: [decoEntity] = []
//    var saveDate: Date = .now
//}
//
//struct decoEntity: Decodable, Encodable, Hashable {
//    var image: Data?
//    var position: SIMD3<Float>?
//    var transform: Transform?
//}
//
//extension DecoEntityModel: Persistable {
//    typealias PersistedObject = DecoEntity
//    
//    init(persistedObject: DecoEntity){
//        let decoder = JSONDecoder()
//        
//        self.id = persistedObject.id
//        self.decoEntities = try! decoder.decode([decoEntity].self, from: persistedObject.decoEntities!)
//        self.saveDate = persistedObject.saveDate
//    }
//    
//    func persistedObject() -> DecoEntity {
//        let encoder = JSONEncoder()
//        let cake = DecoEntity()
//        
//        cake.id = self.id
//        cake.decoEntities = try! encoder.encode(self.decoEntities)
//        cake.saveDate = self.saveDate
//        
//        return cake
//    }
//}
//
//class DecoEntity: Object {
//    @Persisted(primaryKey: true) var id: String
//    @Persisted var decoEntities: Data?
//    @Persisted var saveDate: Date
//}
//
//
//
//
//
//
//
