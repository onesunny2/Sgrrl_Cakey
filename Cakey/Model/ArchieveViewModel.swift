//
//  ArchieveViewModel.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/18/24.
//

import SwiftUI

@Observable
class ArchieveViewModel {
    @ObservationIgnored let realm = RealmManager.shared
    
    // Read
    func readSortedCakeys() -> [CakeyModel] {
        self.realm.readCakey()
            .filter { $0.isComplete == true }
            .sorted(by: {$0.saveDate > $1.saveDate} )
    }
    
    // Delete
    func deleteCakey(key: String) {
        self.realm.deleteCakey(key)
    }
}
