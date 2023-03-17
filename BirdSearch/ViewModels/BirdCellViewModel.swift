//
//  BirdCellViewModel.swift
//  BirdSearch
//
//  Created by Felix Alexander Sotelo Quezada on 19-08-22.
//

import Foundation
import CoreText
import UIKit

enum BirdCellState: Equatable {
    case loaded(model: BirdCellModelVM)
    case loading
    case loadedWithError(error: BirdsErrors)
}
@MainActor
class BirdCellViewModel {
    var birdCell : BirdCellModelVM?
    var refreshCellViewModel : ((BirdCellState) -> Void)?
    var state : BirdCellState = .loading {
        didSet {
            refreshCellViewModel?(state)
        }
    }
    func getCellData(url: String, birdModel: BirdsListModel) async {
        do {
            state = .loading
            let birdImage = try await BirdsService.shared.downloadImage(from: url)
            guard let birdImage = birdImage else { return }
            self.birdCell = BirdCellModelVM(birdCellModel: BirdCellModel(uid: birdModel.index,
                                                                         birdImage: birdImage,
                                                                         titleName: birdModel.birdLatinName,
                                                                         englishName: birdModel.birdEnglishName,
                                                                         spanishName: birdModel.birdSpanishName))
            guard let birdCell = birdCell else { return }
            state = .loaded(model: birdCell)
        } catch  {
            state = .loadedWithError(error: BirdsErrors.invalidData)
        }
    }
    func connectCallback(callback: @escaping (BirdCellState) -> Void) {
        self.refreshCellViewModel = callback
   }
}

struct BirdCellModelVM {
    fileprivate let birdCellModel : BirdCellModel
    
    var uid : Int {
        birdCellModel.uid
    }
    var birdImage : UIImage {
        birdCellModel.birdImage
    }
    var titleName : String {
        birdCellModel.titleName ?? ""
    }
    var englishName : String {
        birdCellModel.englishName ?? ""
    }
    var spanishName : String {
        birdCellModel.spanishName ?? ""
    }
}

extension BirdCellModelVM : Hashable {
    static func == (lhs: BirdCellModelVM, rhs: BirdCellModelVM) -> Bool {
        lhs.uid == rhs.uid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
}
