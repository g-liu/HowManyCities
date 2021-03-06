//
//  State.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/23/22.
//

import Foundation

struct State: Codable, Hashable {
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
  
  init(name: String) {
    self.value = name
    self.name = name
    self.states = nil
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
  
  var nameWithFlag: String {
    if let flag = flag {
      return "\(flag) \(name)"
    } else {
      return name
    }
  }
  
  var searchName: String {
    if let childState = states?.first {
      return childState.name + ", \(normalizedCountryName)"
    }
    
    // Special exception for Georgia the country
    if normalizedCountryName.localizedCaseInsensitiveContains("Georgia") {
      return "??????????????????????????????"
    }
    
    return normalizedCountryName
  }
  
  var locale: String? {
    return Global.COUNTRY_NAMES_TO_LOCALES[normalizedCountryName]
  }
  
  var flag: String? {
    guard let locale = locale else { return nil }
    let base: UInt32 = 127397
    let scalars = locale.unicodeScalars.compactMap { UnicodeScalar(base + $0.value) }
    return .init(scalars)
  }
  
  var normalizedCountryName: String {
    Global.NORMALIZED_COUNTRY_NAMES[name] ?? name
  }
}

extension State: Equatable { }
