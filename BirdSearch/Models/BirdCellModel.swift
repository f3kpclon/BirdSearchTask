//
//  BirdCellModel.swift
//  BirdSearch
//
//  Created by Felix Alexander Sotelo Quezada on 20-08-22.
//

import Foundation
import UIKit

struct BirdCellModel {
    let uid: String
    let birdImage: UIImage
    let titleName: String
    let englishName: String
    let spanishName: String
}

extension BirdCellModel: Hashable {
    static func == (lhs: BirdCellModel, rhs: BirdCellModel) -> Bool {
        lhs.uid == rhs.uid
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
}
