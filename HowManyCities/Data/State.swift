//
//  State.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/23/22.
//

import Foundation

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
  
//  init(value: String, name: String, states: [State]?) {
//    self.value = value
//    self.name = name
//    self.states = states
//  }
  
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

extension State: Equatable { }