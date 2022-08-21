//
//  BirdListViewModel.swift
//  BirdSearch
//
//  Created by Felix Alexander Sotelo Quezada on 19-08-22.
//

import Foundation
enum BirdsListViewModelState: Equatable {
    case loaded(model: [BirdsListModel])
    case loading
    case loadedError(error: BirdsErrors)
}
@MainActor
class BirdListViewModel {
    var birds = [BirdsListModel]()
    var state : BirdsListViewModelState = .loading {
        didSet {
            refreshBirdsViewModel?(state)
        }
    }
    var refreshBirdsViewModel : ((BirdsListViewModelState) -> Void)?
    
    func getBirds() async {
        do {
            state = .loading
            let dataBirds = try await BirdsService.shared.getAllBirds()
            self.birds = dataBirds.map(BirdsListModel.init)
            state = .loaded(model: birds)
        } catch  {
            state = .loadedError(error: .invalidData)
        }
    }
    func connectCallback(callback: @escaping (BirdsListViewModelState) -> Void) {
        self.refreshBirdsViewModel = callback
   }
}

