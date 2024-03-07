// TODO: IF NO LONGER NEEDED, REMOVE!!!
// we'll retain it for the flags

//
//  State.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/23/22.
//

import Foundation

struct State: Codable, Hashable {
  var name: String
  
  enum CodingKeys: String, CodingKey {
    case name
  }
  
  init(name: String) {
    self.name = name
  }
  
  init(from decoder: Decoder) throws { // TODO: FIX as it is just a string scalar
    let values = try decoder.singleValueContainer()
    self.name = try values.decode(String.self)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
  }
  
  var nameWithFlag: String {
    if let flag = flag {
      return "\(flag) \(name)"
    } else {
      return name
    }
  }
  
  var searchName: String {
    // Special exception for Georgia, the country
    if normalizedCountryName.localizedCaseInsensitiveContains("Georgia") {
      return "საქართველო"
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
