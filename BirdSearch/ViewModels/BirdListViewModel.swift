//
//  BirdListViewModel.swift
//  BirdSearch
//
//  Created by Felix Alexander Sotelo Quezada on 19-08-22.
//

import Combine
import Foundation

class BirdListViewModel {
    private var observedBirds = PassthroughSubject<BirdCellModel, Error>()
    var birds: AnyPublisher<[BirdCellModel], Error> {
        return observedBirds
            .collect()
            .eraseToAnyPublisher()
    }

    private let dataManager: BirdsDataManager

    private var task: Task<Void, Never>?

    init(dataManager: BirdsDataManager) {
        self.dataManager = dataManager

        task = Task {
            do {
                let stream = try await dataManager.getBirdsData()

                for try await bird in stream {
                    observedBirds.send(bird)
                }

                observedBirds.send(completion: .finished)
            } catch {
                observedBirds.send(completion: .failure(error))
            }
        }
    }

    deinit {
        task?.cancel()
    }
}

actor BirdsDataManager {
    func getBirdsData() async throws -> AsyncStream<BirdCellModel> {
        let dataBirds = try await BirdsService.shared.getBirdsWithImage()

        return AsyncStream { continuation in
            DispatchQueue.global(qos: .background).async {
                for bird in dataBirds {
                    continuation.yield(bird)
                }
                continuation.finish()
            }
        }
    }
}
