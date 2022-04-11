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
  let states: [State]
  
  var topLevelStates: [State] {
    states.filter { $0.states?.isEmpty ?? true }
  }
}

struct State: Codable {
  var value: String
  var name: String
  var states: [State]?
  
  enum CodingKeys: String, CodingKey {
    case value
    case name
  }
  
  enum AnotherCodingKeys: String, CodingKey {
    case value = "group"
    case name = "label"
    case states
  }
  
  init(from decoder: Decoder) throws {
    do {
      let values = try decoder.container(keyedBy: AnotherCodingKeys.self)
      self.value = try values.decode(String.self, forKey: .value)
      self.name = try values.decode(String.self, forKey: .name)
      self.states = try values.decode([State].self, forKey: .states)
    } catch {
      do {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try values.decode(String.self, forKey: .value)
        self.name = try values.decode(String.self, forKey: .name)
        self.states = nil
      } catch {
        fatalError("You're stupid")
      }
    }
  }
}
