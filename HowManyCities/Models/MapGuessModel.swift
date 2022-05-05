//
//  MapGuessModel.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/23/22.
//

import Foundation
import MapKit
import OrderedCollections

//typealias Ratio = (numerator: Int, denominator: Int)
struct Ratio: Hashable {
  let numerator: Int
  let denominator: Int
}

protocol GameStatisticsProvider: AnyObject {
  var numCitiesGuessed: Int { get }
  var populationGuessed: Int { get }
  
  var citiesByCountry: [String: [City]] { get }
  var citiesByTerritory: [String: [City]] { get }
  
  var nationalCapitalsGuessed: [City] { get }
  
  var largestCitiesGuessed: [City] { get }
  var smallestCitiesGuessed: [City] { get }
  var rarestCitiesGuessed: [City] { get }
  var commonCitiesGuessed: [City] { get }
  var recentCitiesGuessed: [City] { get }
  
  func guessedCities(near city: City) -> [City]
  
  var percentageTotalPopulationGuessed: Double { get }
  
  func citiesExceeding(population: Int) -> [City]
  
  var totalCapitalsGuessed: Ratio { get }
  var totalStatesGuessed: Ratio { get }
  var totalTerritoriesGuessed: Ratio { get }
  
  // key: population bracket
  // value: number of cities guessed vs. total cities in bracket
  var totalGuessedByBracket: [(Int, Ratio)] { get }
}

final class MapGuessModel: Codable {
  var guessedCities: OrderedSet<City> = .init()
  var gameConfiguration: GameConfiguration?
  var startTime: Date = .now
  var usedMultiCityInput: Bool = false
  var lastRegion: MKCoordinateRegion = .init(center: .zero, span: .full)
  
  func resetState() {
    guessedCities = .init()
  }
}

// MARK: - Statistics
// TODO: Perhaps convert this to a protocol that can be used??

extension MapGuessModel: GameStatisticsProvider {
  var numCitiesGuessed: Int { guessedCities.count }
  var populationGuessed: Int { guessedCities.reduce(0) { $0 + $1.population } }
  
  private var citiesGuessedSortedIncreasing: [City] {
    guessedCities.sorted { c1, c2 in
      if c1.population == c2.population {
        if c1.name == c2.name {
          return c1.fullTitle < c2.fullTitle
        }
        return c1.name < c2.name
      }
      return c1.population < c2.population
    }
  }
  
  var citiesByCountry: [String: [City]] {
    var countriesDict = [String: [City]]()
    guessedCities.forEach {
      let country = $0.country
      guard !country.isEmpty else { return }
      countriesDict[country, default: []].append($0)
    }
    
    return countriesDict
  }
  
  var citiesByTerritory: [String: [City]] {
    var territoriesDict = [String: [City]]()
    guessedCities.forEach {
      let territory = $0.territory
      guard !territory.isEmpty else { return }
      territoriesDict[territory, default: []].append($0)
    }
    
    return territoriesDict
  }
  
  var nationalCapitalsGuessed: [City] {
    guessedCities.filter { $0.nationalCapital }
  }
  
  var largestCitiesGuessed: [City] {
    citiesGuessedSortedIncreasing.reversed()
  }
  
  var smallestCitiesGuessed: [City] {
    citiesGuessedSortedIncreasing
  }
  
  var rarestCitiesGuessed: [City] {
    guessedCities.filter { $0.percentageOfSessions != nil }
      .sorted { c1, c2 in
        (c1.percentageOfSessions ?? 0.0) < (c2.percentageOfSessions ?? 0.0)
      }
  }
  
  var commonCitiesGuessed: [City] {
    guessedCities.filter { $0.percentageOfSessions != nil }
      .sorted { c1, c2 in
        (c1.percentageOfSessions ?? 0.0) > (c2.percentageOfSessions ?? 0.0)
      }
  }
  
  var recentCitiesGuessed: [City] {
    guessedCities.reversed()
  }
  
  var percentageTotalPopulationGuessed: Double {
    guard let config = gameConfiguration, config.totalPopulation.asDouble > 0 else {
      return 0
    }
    return populationGuessed / config.totalPopulation.asDouble
  }
  
  func citiesExceeding(population: Int) -> [City] {
    guessedCities.filter { $0.population > population }
  }
  
  func guessedCities(near city: City) -> [City] {
    guessedCities.sorted {
      $0.coordinates.asLocation.distance(from: city.coordinates.asLocation) <
        $1.coordinates.asLocation.distance(from: city.coordinates.asLocation)
    }.dropFirst().asArray
  }
  
  var totalCapitalsGuessed: Ratio {
    .init(numerator: guessedCities.filter { $0.nationalCapital }.count, denominator: gameConfiguration?.totalCapitals ?? 0)
  }
  
  var totalStatesGuessed: Ratio {
    .init(numerator: citiesByCountry.count, denominator: gameConfiguration?.totalStates ?? 0)
  }
  
  var totalTerritoriesGuessed: Ratio {
    .init(numerator: citiesByTerritory.count, denominator: gameConfiguration?.totalTerritories ?? 0)
  }
  
  var totalGuessedByBracket: [(Int, Ratio)] {
    guard let gameConfig = gameConfiguration else { return [] }
    
    return gameConfig.brackets.enumerated().map {
      ($1, .init(numerator: citiesExceeding(population: $1).count, denominator: gameConfig.totalCitiesByBracket[$0]))
    }
  }
}


enum CityGuessError: Error {
  case noneFound(_ cityName: String)
  case alreadyGuessed
  case emptyGuess
  case serverError
  
  var message: String {
    switch self {
      case .noneFound(let name):
        return "No city named \(name.capitalized) found!"
      case .alreadyGuessed:
        return "Already guessed!"
      case .emptyGuess:
        return "Please enter a city name"
      case .serverError:
        return "We're having technical issues, please try again"
    }
  }
  
  var toastType: ToastType {
    switch self {
      case .noneFound(_),
          .emptyGuess,
          .serverError:
        return .error
      case .alreadyGuessed:
        return .warning
    }
  }
}
