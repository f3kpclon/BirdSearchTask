//
//  BirdZoomModel.swift
//  BirdSearch
//
//  Created by Felix Alexander Sotelo Quezada on 21-08-22.
//

import Foundation
import UIKit

struct BirdZoomModel {
    let uid: Int
    let title: String
    let zoomImage: UIImage
}

extension BirdZoomModel: Hashable {
    static func == (lhs: BirdZoomModel, rhs: BirdZoomModel) -> Bool {
        lhs.uid == rhs.uid
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
}
