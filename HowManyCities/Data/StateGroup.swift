
//
//  StateGroup.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 2/14/24.
//

import Foundation

struct StateGroup: Codable, Hashable {
  var group: String
  var label: String
  var states: [State]

  init(group: String, label: String, states: [State]) {
    self.group = group
    self.label = label
    self.states = states
  }
  
  enum CodingKeys: String, CodingKey {
    case group
    case label
    case states
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.group = try values.decode(String.self, forKey: .group)
    self.label = try values.decode(String.self, forKey: .label)
    self.states = try values.decode([State].self, forKey: .states)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(group, forKey: .group)
    try container.encode(label, forKey: .label)
    try container.encode(states, forKey: .states)
  }

  var nameWithFlag: String {
    if let flag = flag {
      return "\(flag) \(group)"
    } else {
      return group
    }
  }

  // TODO: UNDUPE CODE where necessary
  func searchName(forState atIndex: Int) -> String {
    let countrySearchName: String
    let stateSearchName: String
    
    // Special exception for Georgia the country
    if normalizedCountryName.localizedCaseInsensitiveContains("Georgia") {
      countrySearchName = "საქართველო"
    } else {
      countrySearchName = normalizedCountryName
    }
    
    stateSearchName = states[atIndex].searchName
    
    return "\(stateSearchName), \(countrySearchName)"
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
    Global.NORMALIZED_COUNTRY_NAMES[group] ?? group
  }
}

extension StateGroup: Equatable { }
