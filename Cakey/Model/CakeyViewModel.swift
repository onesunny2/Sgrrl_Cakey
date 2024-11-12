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
    
    init(cakeyModel: CakeyModel) {
        self.cakeyModel = cakeyModel
        self.realm.addCakey(cakeyModel)  // Create
    }
    
    // Read
    func readSortedCakeys() -> [CakeyModel] {
        self.realm.readCakey().sorted(by: {$0.saveDate > $1.saveDate} )
    }
    
    // Update
    func updateCakey() {
        self.realm.updateCakey(self.cakeyModel)
    }
    
    // Delete
    func deleteCakey(key: String) {
        self.realm.deleteCakey(key)
    }
}
