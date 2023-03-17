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
    private let manager = AsyncPublisherManager()

  init() {
    
    addSubscriber()
  }

  private func addSubscriber() {
    Task {
      for await value in await manager.$data.values {
        self.birdsList = value
      }
    }
  }
  func getBirdsData() async {
    await manager.getBirdsData()
  }
}

actor AsyncPublisherManager {
  @Published var data : [BirdsListModel] = []
  func getBirdsData() async {
      do {
          let dataBirds = try await BirdsService.shared.getAllBirds()
          self.data = dataBirds.map(BirdsListModel.init)
      } catch  {
          print(error)
      }
  }

}
