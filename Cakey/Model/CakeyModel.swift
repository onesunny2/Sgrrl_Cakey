//
//  CakeyModel.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/4/24.
//

import Foundation
import RealmSwift

struct CakeyModel: Hashable {
    var id: String = UUID().uuidString
    var cakeColor: String?
    var letteringText: String?
    var letteringColor: String?
    var cakeImages: [decoElements] = []
    var cakeArImage: Data?
    var saveDate: Date = .now
    var isComplete: Bool = false
}

struct decoElements: Decodable, Encodable, Hashable {
    var image: Data
    var description: String
}

extension CakeyModel: Persistable {
    typealias PersistedObject = CakeyEntity
    
    init(persistedObject: CakeyEntity) {
        let decoder = JSONDecoder()
        
        self.id = persistedObject.id
        self.cakeColor = persistedObject.cakeColor
        self.letteringText = persistedObject.letteringText
        self.letteringColor = persistedObject.letteringColor
        self.cakeImages = try! decoder.decode([decoElements].self, from: persistedObject.cakeImages!)
        self.cakeArImage = persistedObject.cakeArImage
        self.saveDate = persistedObject.saveDate
        self.isComplete = persistedObject.isCompleted
    }
    
    func persistedObject() -> CakeyEntity {
        let encoder = JSONEncoder()
        let cakey = CakeyEntity()
        
        cakey.id = self.id
        cakey.cakeColor = self.cakeColor
        cakey.letteringText = self.letteringText
        cakey.letteringColor = self.letteringColor
        cakey.cakeImages = try! encoder.encode(self.cakeImages)
        cakey.cakeArImage = self.cakeArImage
        cakey.saveDate = self.saveDate
        cakey.isCompleted = self.isComplete
        
        return cakey
    }
}


class CakeyEntity: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var cakeColor: String?
    @Persisted var letteringText: String?
    @Persisted var letteringColor: String?
    @Persisted var cakeImages: Data?
    @Persisted var cakeArImage: Data?
    @Persisted var saveDate: Date
    @Persisted var isCompleted: Bool
}


