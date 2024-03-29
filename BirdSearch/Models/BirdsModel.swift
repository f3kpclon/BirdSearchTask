//
//  BirdsModel.swift
//  BirdSearch
//
//  Created by Felix Alexander Sotelo Quezada on 19-08-22.
//

import Foundation

struct BirdsModel: Codable {
    let uid: String
    let name: BirdsName
    let images: BirdsImage
    let sort: Int
}

struct BirdsName: Codable, Hashable {
    let spanish: String
    let english: String
    let latin: String
}

struct BirdsImage: Codable, Hashable {
    let thumb: String
    let full: String
}

extension BirdsModel: Hashable {
    static func == (lhs: BirdsModel, rhs: BirdsModel) -> Bool {
        lhs.uid == rhs.uid
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
}
