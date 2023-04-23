//
//  UIDiffableDataSource+Ext.swift
//  BirdSearch
//
//  Created by Felix Alexander Sotelo Quezada on 21-08-22.
//
import UIKit

extension UICollectionViewDiffableDataSource {
    /// Reapplies the current snapshot to the data source, animating the differences.
    /// - Parameters:
    ///   - completion: A closure to be called on completion of reapplying the snapshot.
    func refresh(completion: (() -> Void)? = nil) {
        apply(snapshot(), animatingDifferences: true, completion: completion)
    }
}
