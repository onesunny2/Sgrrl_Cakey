//
//  CakeyViewModel.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/10/24.
//

import Foundation
import SwiftUI


@Observable
class CakeyViewModel {
    
    @ObservationIgnored let realm = RealmManager.shared
    
    var cakeyModel: CakeyModel
    var decoModel: DecoEntityModel
    
    init(cakeyModel: CakeyModel, decoModel: DecoEntityModel) {
        self.cakeyModel = cakeyModel
        self.decoModel = decoModel
        self.realm.addCakey(cakeyModel)  // Create
        self.realm.addDecoEntity(decoModel)
    }
    
    // Update
    func updateCakey() {
        self.realm.updateCakey(self.cakeyModel)
    }
    
    func updateDeco() {
        self.realm.updateDecoEntity(self.decoModel)
    }
    
    // Read
    func readDeco() -> DecoEntityModel? {
        self.realm.readLatestDecoEntity()
    }
}
