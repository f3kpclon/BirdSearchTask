//
//  BirdListViewModel.swift
//  BirdSearch
//
//  Created by Felix Alexander Sotelo Quezada on 19-08-22.
//

import Foundation

@MainActor
class BirdListViewModel: ObservableObject {
    @Published var birdsList = [BirdsListModel]()
    private let dataManager: BirdsDataManager

    private var task: Task<Void, Never>?

    init(dataManager: BirdsDataManager) {
        self.dataManager = dataManager
        addSubscriber()
    }

    deinit {
        task?.cancel()
    }

    private func addSubscriber() {
        task = Task { [weak self] in
            guard let self else { return }
            for await value in await self.dataManager.$data.values {
                self.birdsList = value
            }
        }
    }

    func getBirdsData() async {
        do {
            try await dataManager.getBirdsData()
        } catch {
            // handle error
            print(error)
        }
    }
}

actor BirdsDataManager {
    @Published var data: [BirdsListModel] = []
    @Published var cellData: BirdCellModelVM?

    func getBirdsData() async throws {
        let dataBirds = try await BirdsService.shared.getAllBirds()
        data = dataBirds.map(BirdsListModel.init)
    }

    func getCellData(url: String, birdModel: BirdsListModel) async throws {
        guard let birdImage = try await BirdsService.shared.downloadImage(from: url) else {
            return
        }

        cellData = BirdCellModelVM(
            birdCellModel: BirdCellModel(
                uid: birdModel.index,
                birdImage: birdImage,
                titleName: birdModel.birdLatinName,
                englishName: birdModel.birdEnglishName,
                spanishName: birdModel.birdSpanishName
            )
        )
    }
}
