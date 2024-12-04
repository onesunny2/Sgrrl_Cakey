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


// MARK: Cake3D CRUD
extension RealmManager {

    // MARK: Create
    func addDecoEntity(_ decoEntityModel: DecoEntityModel) {
        print(#fileID, #function, #line, "경로: \(Realm.Configuration.defaultConfiguration.fileURL!)")
        
        let decoEntity = decoEntityModel.persistedObject()
        
        do {
            try realm.write {
                realm.add(decoEntity)
                print("DecoEntity 추가 성공: \(decoEntity)")
            }
        } catch {
            print("DecoEntity 추가 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: Update
    func updateDecoEntity(_ decoEntityModel: DecoEntityModel) {
        print(#fileID, #function, #line, "Realm 업데이트 시작")
        
        let decoEntity = decoEntityModel.persistedObject()
        
        do {
            try realm.write {
                realm.add(decoEntity, update: .modified)
                print("DecoEntity 업데이트 성공: \(decoEntity)")
            }
        } catch {
            print("DecoEntity 업데이트 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: Read
    func readDecoEntity(id: String) -> DecoEntityModel? {
        print(#fileID, #function, #line, "Realm 읽기 시작")
        
        guard let decoEntity = realm.object(ofType: DecoEntity.self, forPrimaryKey: id) else {
            print("DecoEntityModel 읽기 실패: ID \(id)로 객체를 찾을 수 없음")
            return nil
        }
        
        let decoEntityModel = DecoEntityModel(persistedObject: decoEntity)
        print("DecoEntityModel 읽기 성공: \(decoEntityModel)")
        return decoEntityModel
    }
    
    // MARK: ⭐️⭐️⭐️ Read (가장 최근 객체 가져오기)
    func readLatestDecoEntity() -> DecoEntityModel? {
        print(#fileID, #function, #line, "Realm 최근 데이터 읽기 시작")
        
        guard let decoEntity = realm.objects(DecoEntity.self).sorted(byKeyPath: "createdAt", ascending: false).first else {
            print("DecoEntityModel 읽기 실패: 최근 데이터를 찾을 수 없음")
            return nil
        }
        
        let decoEntityModel = DecoEntityModel(persistedObject: decoEntity)
        print("DecoEntityModel 최근 데이터 읽기 성공: \(decoEntityModel)")
        return decoEntityModel
    }
    
    // MARK: Delete
    func deleteDecoEntity(id: String) {
        print(#fileID, #function, #line, "Realm 삭제 시작")
        
        guard let decoEntity = realm.object(ofType: DecoEntity.self, forPrimaryKey: id) else {
            print("DecoEntity 삭제 실패: ID \(id)로 객체를 찾을 수 없음")
            return
        }
        
        do {
            try realm.write {
                realm.delete(decoEntity)
                print("DecoEntity 삭제 성공: ID \(id)")
            }
        } catch {
            print("DecoEntity 삭제 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: Delete (모든 데이터 삭제)
    func deleteAllDecoEntities() {
        print(#fileID, #function, #line, "Realm 모든 데이터 삭제 시작")
        
        let allDecoEntities = realm.objects(DecoEntity.self)
        
        do {
            try realm.write {
                realm.delete(allDecoEntities)
                print("모든 DecoEntity 삭제 성공")
            }
        } catch {
            print("모든 DecoEntity 삭제 실패: \(error.localizedDescription)")
        }
    }
}




