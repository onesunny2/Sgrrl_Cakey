//
//  RealmManager.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/10/24.
//

import Foundation
import SwiftUI
import RealmSwift

class RealmManager {
    
    static let shared = RealmManager()
    
    private init() {}
    
    let realm = try! Realm()
    
    // Create
    func addCakey(_ cakeyModel: CakeyModel) {
        //log 출력
        print(#fileID, #function, #line, "경로: \(Realm.Configuration.defaultConfiguration.fileURL!)")
        
        let cakey = cakeyModel.persistedObject()
        
        try! realm.write {
            realm.add(cakey)
        }
    }
    
    // Read
    func readCakey() -> [CakeyModel] {
        
        let cakeys = realm.objects(CakeyEntity.self)
        
        return cakeys.map{ CakeyModel(persistedObject: $0) }
    }
    
    // Update
    func updateCakey(_ cakeyModel: CakeyModel) {
        
        let cakey = cakeyModel.persistedObject()
        let updateCakey = realm.object(ofType: CakeyEntity.self, forPrimaryKey: cakey.id)
        
        try! realm.write {
            realm.add(cakey, update: .modified)
        }
    }
    
    // Delete
    func deleteCakey(_ key: String) {
        
        guard let object = realm.object(ofType: CakeyEntity.self, forPrimaryKey: key) else { return }        
        
        try! realm.write {
            realm.delete(object)
        }
    }
}


