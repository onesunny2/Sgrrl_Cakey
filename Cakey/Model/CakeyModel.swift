//
//  CakeyModel.swift
//  Cakey
//
//  Created by Lee Wonsun on 11/4/24.
//

import Foundation

struct CakeyModel {
    var cakeColor: String?
    var letteringText: String?
    var letteringColor: String?
    var cakeImages: [decoElements] = []
}

struct decoElements {
    var image: Data
    var description: String
}
