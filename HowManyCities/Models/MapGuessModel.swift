//
//  MapGuessModel.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/23/22.
//

import Foundation
import MapKit
import OrderedCollections

protocol GameStatisticsDelegate: AnyObject {
  var numCitiesGuessed: Int { get }
  var populationGuessed: Int { get }
  
  var citiesByCountry: [String: [City]] { get }
  var citiesByTerritory: [String: [City]] { get }
  
  var nationalCapitalsGuessed: [City] { get }
  
  var largestCitiesGuessed: [City] { get }
  var smallestCitiesGuessed: [City] { get }
  var rarestCitiesGuessed: [City] { get }
  
  var percentageTotalPopulationGuessed: Double { get }
  
  func citiesExceeding(population: Int) -> [City]
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

extension MapGuessModel: GameStatisticsDelegate {
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
    citiesGuessedSortedIncreasing.suffix(10).reversed()
  }
  
  var smallestCitiesGuessed: [City] {
    citiesGuessedSortedIncreasing.prefix(10).asArray
  }
  
  var rarestCitiesGuessed: [City] {
    guessedCities.sorted { c1, c2 in
      (c1.percentageOfSessions ?? 0.0) < (c2.percentageOfSessions ?? 0.0)
    }.prefix(10).asArray
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
}
