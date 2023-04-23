//
//  BirdZoomViewModel.swift
//  BirdSearch
//
//  Created by Felix Alexander Sotelo Quezada on 21-08-22.
//

import Foundation

enum BirdZoomstate: Equatable {
    case loaded(model: BirdZoomModel)
    case loading
    case loadedWithError(error: BirdsErrors)
}

@MainActor
class BirdZoomViewModel {
    var birdZoom: BirdZoomModel?
    var refreshCellViewModel: ((BirdZoomstate) -> Void)?
    var state: BirdZoomstate = .loading {
        didSet {
            refreshCellViewModel?(state)
        }
    }

    func getBirdZoomData(url: String, birdModel: BirdsListModel) async {
        do {
            state = .loading
            let birdImage = try await BirdsService.shared.downloadImage(from: url)
            guard let birdImage = birdImage else { return }
            self.birdZoom = BirdZoomModel(uid: birdModel.index,
                                          title: birdModel.birdSpanishName,
                                          zoomImage: birdImage)
            guard let birdZoom = birdZoom else { return }
            state = .loaded(model: birdZoom)
        } catch {
            state = .loadedWithError(error: BirdsErrors.invalidData)
        }
    }

    func connectCallback(callback: @escaping (BirdZoomstate) -> Void) {
        refreshCellViewModel = callback
    }
}
