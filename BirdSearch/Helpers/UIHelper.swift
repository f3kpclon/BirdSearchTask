//
//  UIHelper.swift
//  BirdSearch
//
//  Created by Felix Alexander Sotelo Quezada on 19-08-22.
//

import UIKit
struct UIHelper {
    static func createSingleColumnFlowLayout(in view : UIView) -> UICollectionViewFlowLayout {
        let width = view.bounds.width
        let flowLayaout            = UICollectionViewFlowLayout()
        flowLayaout.itemSize       = CGSize(width: width, height: 100)
        return flowLayaout
    }
}
