//
//  GameConfiguration.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import Foundation

struct GameConfiguration: Codable {
  // Not all properties included
  let brackets: [Int]
  let hasStates: Bool
  let placeholder: String
  let maxCities: Int
  let missingCitiesCutoff: Int
  let totalCapitals: Int
  let totalStates: Int
  let totalTerritories: Int
  let totalPopulation: Int
  let totalCitiesByBracket: [Int]
  // TODO: some states are in the form:
  // {group, label, states: []}
  // states is another nested level... sigh
  // dunt know if we want to handle this case
//  let states: [State]
}

struct State: Codable {
  let value: String
  let name: String
}
