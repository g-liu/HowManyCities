//
//  GameFinishRequestBody.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/30/22.
//

import Foundation

struct GameFinishRequestBody: Codable {
  let cities: [CityShortForm]
  let quiz: String
  let startTime: Int
  let usedMultiCityInput: Bool
}

struct CityShortForm: Codable { // TODO: Protocolize this?
  let pk: Int
  let name: String
}
