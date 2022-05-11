//
//  MapGuessModel.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/23/22.
//

import Foundation
import MapKit
import OrderedCollections

protocol GameStatisticsProvider: AnyObject {
  var numCitiesGuessed: Int { get }
  var populationGuessed: Int { get }
  
  var citiesByCountry: [String: [City]] { get }
  var citiesByTerritory: [String: [City]] { get }
  var citiesByPopulation: [Int: [City]] { get }
  var citiesByRarity: [Double: [City]] { get }
  
  var nationalCapitalsGuessed: [City] { get }
  
  var recentCitiesGuessed: [City] { get }
  
  /// A list of cities, sorted by closest to the given city.
  /// Only cities within the threshold distance are considered
  /// - Parameters:
  ///   - city: the reference city
  ///   - threshold: the maximum distance until a city is no longer considered "close"
  ///   - limit: the maximum number of cities returned
  /// - Returns: the cities closest to given city, sorted in order of distance, up to the limit
  func guessedCities(near city: City, threshold: Double, limit: Int) -> [City]
  func nearestCity(to city: City) -> City?
  
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

extension MapGuessModel: GameStatisticsProvider {
  var numCitiesGuessed: Int { guessedCities.count }
  var populationGuessed: Int { guessedCities.reduce(0) { $0 + $1.population } }
  
  var citiesByCountry: [String: [City]] {
    var dict = Dictionary(grouping: guessedCities, by: \.country)
    dict.removeAll(keys: gameConfiguration?.excludeStates ?? [])
    return dict
  }
  
  var citiesByTerritory: [String: [City]] {
    var dict = Dictionary(grouping: guessedCities, by: \.territory)
    dict.removeAll(keys: [""])
    return dict
  }
  
  var citiesByRarity: [Double : [City]] {
    var dict = Dictionary(grouping: guessedCities) { $0.percentageOfSessions ?? -1.0 }
    dict.removeAll(keys: [-1.0])
    return dict
  }
  
  var citiesByPopulation: [Int : [City]] {
    .init(grouping: guessedCities, by: \.population)
  }
  
  var nationalCapitalsGuessed: [City] {
    guessedCities.filter(by: \.nationalCapital)
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
  
  func guessedCities(near city: City, threshold: Double = 500_000, limit: Int = 10) -> [City] {
    var i = 0
    return guessedCities.sorted {
      $0.coordinates.asLocation.distance(from: city.coordinates.asLocation) <
        $1.coordinates.asLocation.distance(from: city.coordinates.asLocation)
    }.dropFirst().prefix {
      if i >= 10 { return false }
      if $0.distance(to: city) > threshold { return false }
      i += 1
      return true
    }
  }
  
  func nearestCity(to city: City) -> City? {
    guard guessedCities.count > 1 else { return nil }
    return guessedCities.max {
      let distance0 = $0.distance(to: city)
      let distance1 = $1.distance(to: city)
      return distance0 > distance1 && $0 != city && $1 != city
    }
  }
  
  var totalCapitalsGuessed: Ratio {
    .init(numerator: guessedCities.filter(by: \.nationalCapital).count, denominator: gameConfiguration?.totalCapitals ?? 0)
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
