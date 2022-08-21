//
//  BirdsErrors.swift
//  BirdSearch
//
//  Created by Felix Alexander Sotelo Quezada on 19-08-22.
//

import Foundation

enum BirdsErrors: String, Error {
    case badURl             = "Unable to complete your request"
    case invalidResponse    = "Invalid Response from the server"
    case invalidData        = "Data invalid from server"
    }
