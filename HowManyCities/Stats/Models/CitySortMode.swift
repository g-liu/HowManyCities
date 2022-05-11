//
//  CitySortMode.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/10/22.
//

import Foundation

enum CitySortMode: CaseIterable, CustomStringConvertible {
  case recent
  case aToZ
  case countryAToZ
  case populationDescending
  case rarityAscending
  
  var description: String {
    switch self {
      case .recent:
        return "Recent cities"
      case .aToZ:
        return "Cities A→Z"
      case .countryAToZ:
        return "Cities A→Z by country"
      case .populationDescending:
        return "Largest cities"
      case .rarityAscending:
        return "Rarest cities"
    }
  }
  
  // TODO: Could make ext?
  var nextMode: Self {
    let nextIndex = ((Self.allCases.firstIndex(of: self) ?? -1) + 1) % Self.allCases.count
    return Self.allCases[nextIndex]
  }
  
  var showsRarity: Bool {
    // TODO: Make this an ENUM or part of the renderer or SOMETHING needs to be more stateful!
    self == .rarityAscending
  }
}

// TODO: Coalesce into above?
enum StateSortMode: CaseIterable {
  case cityCount
  case population
  
  var nextMode: Self {
    let nextIndex = ((Self.allCases.firstIndex(of: self) ?? -1) + 1) % Self.allCases.count
    return Self.allCases[nextIndex]
  }
}
