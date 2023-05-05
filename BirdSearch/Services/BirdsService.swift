//
//  BirdsService.swift
//  BirdSearch
//
//  Created by Felix Alexander Sotelo Quezada on 19-08-22.
//

import Foundation
import UIKit

class BirdsService {
    let cache = NSCache<NSString, UIImage>()
    let decoder = JSONDecoder()
    static let shared = BirdsService()

    private init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }

  func getAllBirds<T: Decodable>(for: T.Type) async throws -> T {
        let url = Constants.BirdsURL.apiURL
        guard let apiUrl = URL(string: url) else { throw BirdsErrors.badURl }
        async let (birdData, response) = URLSession.shared.data(from: apiUrl)

        guard let response = try await response as? HTTPURLResponse, response.statusCode == 200 else {
            throw BirdsErrors.invalidResponse
        }

        guard let bird = try? decoder.decode(T.self, from: await birdData) else {
            throw BirdsErrors.invalidData
        }
        return bird
    }

    func downloadImage(from urlString: String) async throws -> UIImage? {
        let cacheKey = NSString(string: urlString)
        if let image = cache.object(forKey: cacheKey) { return image }
        guard let url = URL(string: urlString) else { return nil }

        do {
            async let (data, _) = URLSession.shared.data(from: url)
            guard let image = try UIImage(data: await data) else { return nil }
            cache.setObject(image, forKey: cacheKey)
            return image
        } catch {
            return nil
        }
    }

    func getBirdsWithImage() async throws -> [BirdCellModel] {
      let birds = try await getAllBirds(for: [BirdsModel].self)
        return try await withThrowingTaskGroup(of: BirdCellModel.self) { group in
            var birdsModel = [BirdCellModel]()
            for bird in birds {
                group.addTask {
                    let image = try await self.downloadImage(from: bird.images.thumb)!
                    let birdModel = BirdCellModel(
                        uid: bird.uid,
                        birdImage: image,
                        titleName: bird.name.latin,
                        englishName: bird.name.english,
                        spanishName: bird.name.spanish
                    )
                    return birdModel
                }
            }

            for try await bird in group {
                birdsModel.append(bird)
            }
            return birdsModel
        }
    }
}
