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
  case populationAscending
  case rarityAscending
  case rarityDescending
  
  var description: String {
    switch self {
      case .recent:
        return "Most recent"
      case .aToZ:
        return "Alphabetical"
      case .countryAToZ:
        return "Alphabetical by country"
      case .populationDescending:
        return "Most populous"
      case .populationAscending:
        return "Least populous"
      case .rarityAscending:
        return "Least guessed"
      case .rarityDescending:
        return "Most commonly guessed"
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
enum StateSortMode: CaseIterable, CustomStringConvertible {
  case cityCount
  case population
  
  var nextMode: Self {
    let nextIndex = ((Self.allCases.firstIndex(of: self) ?? -1) + 1) % Self.allCases.count
    return Self.allCases[nextIndex]
  }
  
  var description: String {
    switch self {
      case .cityCount:
        return "Most cities guessed"
      case .population:
        return "Total population guessed"
    }
  }
}
