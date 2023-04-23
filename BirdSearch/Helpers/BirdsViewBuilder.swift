//
//  CustomViews.swift
//  BirdSearch
//
//  Created by Felix Alexander Sotelo Quezada on 20-08-22.
//

import Foundation
import UIKit
enum BirdsViewBuilder: BirdsBuilderProvider {
    static func createImageWith(image: UIImage?, contentMode: UIView.ContentMode, clipToBounds: Bool, cornerRadius: Double = 0.0) -> UIImageView {
        let uim = UIImageView()
        uim.image = image
        uim.contentMode = contentMode
        uim.clipsToBounds = clipToBounds
        uim.layer.cornerRadius = cornerRadius
        return uim
    }

    static func createStackWith(alignment: UIStackView.Alignment, axis: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution, spacing: CGFloat = 8.0) -> UIStackView {
        let uis = UIStackView()
        uis.axis = axis
        uis.alignment = alignment
        uis.distribution = distribution
        uis.spacing = spacing
        return uis
    }

    static func createView() -> UIView {
        return UIView()
    }

    static func createScrollView() -> UIScrollView {
        let uisv = UIScrollView()
        uisv.bounces = true
        uisv.contentInsetAdjustmentBehavior = .never
        uisv.showsHorizontalScrollIndicator = false
        uisv.isDirectionalLockEnabled = false
        uisv.alwaysBounceHorizontal = false
        return UIScrollView()
    }

    static func createLabel(color: UIColor?, text: String?, alignment: NSTextAlignment, font: UIFont?, bgColor: UIColor?) -> UILabel {
        let label = UILabel()
        label.text = text
        if let color = color {
            label.textColor = color
        } else {
            label.textColor = .gray
        }
        label.textAlignment = alignment
        if let font = font {
            label.font = font
        } else {
            label.font = .systemFont(ofSize: 12)
        }
        if let bgColor = bgColor {
            label.backgroundColor = bgColor
        }

        return label
    }
}

protocol BirdsBuilderProvider {
    static func createStackWith(alignment: UIStackView.Alignment, axis: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution, spacing: CGFloat) -> UIStackView
    static func createView() -> UIView
    static func createScrollView() -> UIScrollView
    static func createLabel(color: UIColor?, text: String?, alignment: NSTextAlignment, font: UIFont?, bgColor: UIColor?) -> UILabel
    static func createImageWith(image: UIImage?, contentMode: UIView.ContentMode, clipToBounds: Bool, cornerRadius: Double) -> UIImageView
}
