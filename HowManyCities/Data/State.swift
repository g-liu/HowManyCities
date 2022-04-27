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
  
  var searchName: String {
    if let childState = states?.first {
      return childState.searchName + ", \(normalizedCountryName)"
    }
    
    return name
  }
  
  var locale: String {
    return Global.COUNTRY_NAMES_TO_LOCALES[normalizedCountryName] ?? ""
  }
  
  var flag: String {
    let base: UInt32 = 127397
    var s = ""
    for v in locale.unicodeScalars {
      s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
    }
    return String(s)
  }
  
  var normalizedCountryName: String {
    Global.NORMALIZED_COUNTRY_NAMES[name] ?? name
  }
}

extension State: Equatable { }
