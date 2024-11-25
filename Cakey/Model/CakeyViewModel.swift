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
    
    // Update
    func updateCakey() {
        self.realm.updateCakey(self.cakeyModel)
    }
}
