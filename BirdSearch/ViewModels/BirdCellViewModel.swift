//
//  BirdCellViewModel.swift
//  BirdSearch
//
//  Created by Felix Alexander Sotelo Quezada on 19-08-22.
//

import Foundation
import CoreText
import UIKit

@MainActor
class BirdCellViewModel: ObservableObject {
    @Published var birdCell: BirdCellModelVM?
    private let dataManager: BirdsDataManager
    private var task: Task<Void, Never>?

    init(dataManager: BirdsDataManager) {
        self.dataManager = dataManager
        addSubscriber()
    }

    deinit {
        task?.cancel()
    }

    private func addSubscriber()  {
        task = Task {
            for await value in await dataManager.$cellData.values {
                self.birdCell = value
            }
        }
    }

    func getBirdsCellData(url: String, birdModel: BirdsListModel) async throws {
        try await dataManager.getCellData(url: url, birdModel: birdModel)
    }
}


struct BirdCellModelVM {
    let birdCellModel : BirdCellModel
    
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
