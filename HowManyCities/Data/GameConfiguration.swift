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
  
  var lowerDivisionStates: [State] {
    states.filter { !($0.states?.isEmpty ?? true) }
  }
}

struct State: Codable {
  var value: String
  var name: String
  var states: [State]?
  
  enum BaseCodingKeys: String, CodingKey {
    case value
    case name
  }
  
  enum RecursiveCodingKeys: String, CodingKey {
    case value = "group"
    case name = "label"
    case states
  }
  
  init(from decoder: Decoder) throws {
    do {
      // Nested level of states
      let values = try decoder.container(keyedBy: RecursiveCodingKeys.self)
      self.value = try values.decode(String.self, forKey: .value)
      self.name = try values.decode(String.self, forKey: .name)
      self.states = try values.decode([State].self, forKey: .states)
    } catch {
      do {
        // No nested levels
        let values = try decoder.container(keyedBy: BaseCodingKeys.self)
        self.value = try values.decode(String.self, forKey: .value)
        self.name = try values.decode(String.self, forKey: .name)
        self.states = nil
      } catch {
        fatalError("Well shit")
      }
    }
  }
  
  func encode(to encoder: Encoder) throws {
    // depends on if it's nested or not
    if !(states?.isEmpty ?? true) {
      // nested encoding OH BOYYYYY
      var container = encoder.container(keyedBy: RecursiveCodingKeys.self)
      try container.encode(value, forKey: .value)
      try container.encode(name, forKey: .name)
      try container.encode(states, forKey: .states)
    } else {
      // that's all
      var container = encoder.container(keyedBy: BaseCodingKeys.self)
      try container.encode(value, forKey: .value)
      try container.encode(name, forKey: .name)
    }
    
  }
}
