//
//  Cities.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import Foundation

struct Cities: Codable {
  let cities: [City]
}

struct City: Codable {
  let name: String
  let state: String
  let territory: String
  let country: String
  let latitude: Double
  let longitude: Double
  let population: Int
  let stateCapital: Bool
  let nationalCapital: Bool
  let pk: Int
//  let code: AnyObject // I HAVE NO FUCKING CLUE
  let quiz: String
  let archived: Bool
  let percentageOfSessions: Double
}
