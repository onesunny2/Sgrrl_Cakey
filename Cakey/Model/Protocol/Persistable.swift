//
//  Persistable.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/10/24.
//

import RealmSwift

public protocol Persistable {
    associatedtype PersistedObject: RealmSwift.Object
    init(persistedObject: PersistedObject)
    func persistedObject() -> PersistedObject
}
