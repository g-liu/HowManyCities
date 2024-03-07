//
//  GameConfiguration.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import Foundation

struct GameConfiguration: Codable {
  let adjective: String
  let beta: Bool
  let brackets: [Int]
  let convertPostalCodes: Bool
  let excludeStates: [String]
  let hasStates: Bool
  let link: String
  let linkText: String
  let longDivisionNamePlural: String
  let maxCities: Int
  let missingCitiesCutoff: Int
  let placeholder: String
  let populationDescription: String
  let promotion: String
  let promotionLink: String
  let shortDivisionName: String
  let shortDivisionNamePlural: String
  let specialCapital: Bool
  let specialCapitalName: String
  let states: [State]
  let stateGroups: [StateGroup]
  let totalCapitals: Int
  let totalStates: Int
  let totalTerritories: Int
  let name: String
  let totalPopulation: Int
  let totalCitiesByBracket: [Int]
  
  init(adjective: String = "",
    beta: Bool = false,
    brackets: [Int] = [],
    convertPostalCodes: Bool = false,
    excludeStates: [String] = [],
    hasStates: Bool = false,
    link: String = "",
    linkText: String = "",
    longDivisionNamePlural: String = "",
    maxCities: Int = .max,
    missingCitiesCutoff: Int = .max,
    placeholder: String = "",
    populationDescription: String = "",
    promotion: String = "",
    promotionLink: String = "",
    shortDivisionName: String = "",
    shortDivisionNamePlural: String = "",
    specialCapital: Bool = false,
    specialCapitalName: String = "",
    states: [State] = [],
    stateGroups: [StateGroup] = [],
    totalCapitals: Int = 0,
    totalStates: Int = 0,
    totalTerritories: Int = 0,
    name: String = "",
    totalPopulation: Int = 0,
    totalCitiesByBracket: [Int] = []) {
      self.adjective = adjective
      self.beta = beta
      self.brackets = brackets
      self.convertPostalCodes = convertPostalCodes
      self.excludeStates = excludeStates
      self.hasStates = hasStates
      self.link = link
      self.linkText = linkText
      self.longDivisionNamePlural = longDivisionNamePlural
      self.maxCities = maxCities
      self.missingCitiesCutoff = missingCitiesCutoff
      self.placeholder = placeholder
      self.populationDescription = populationDescription
      self.promotion = promotion
      self.promotionLink = promotionLink
      self.shortDivisionName = shortDivisionName
      self.shortDivisionNamePlural = shortDivisionNamePlural
      self.specialCapital = specialCapital
      self.specialCapitalName = specialCapitalName
      self.states = states
      self.stateGroups = stateGroups
      self.totalCapitals = totalCapitals
      self.totalStates = totalStates
      self.totalTerritories = totalTerritories
      self.name = name
      self.totalPopulation = totalPopulation
      self.totalCitiesByBracket = totalCitiesByBracket
  }
}

