//
//  BirdsListModel.swift
//  BirdSearch
//
//  Created by Felix Alexander Sotelo Quezada on 19-08-22.
//

import Foundation

struct BirdsListModel {
    let birdModel : BirdsModel
    var uid : String {
        birdModel.uid
    }
    var birdThumb : String {
        birdModel.images.thumb
    }
    var birdFull : String {
        birdModel.images.full
    }
    var birdLatinName : String {
        birdModel.name.latin
    }
    var birdEnglishName : String {
        birdModel.name.english
    }
    var birdSpanishName : String {
        birdModel.name.spanish
    }
    var index : Int {
        birdModel.sort
    }
}

extension BirdsListModel: Hashable {
    static func == (lhs: BirdsListModel, rhs: BirdsListModel) -> Bool {
        lhs.uid == rhs.uid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
}
