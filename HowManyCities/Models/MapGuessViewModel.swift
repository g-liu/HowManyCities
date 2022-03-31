//
//  MapGuessViewModel.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import Foundation

protocol MapGuessDelegate: AnyObject {
  func didReceiveCities(_ cities: [City])
  func didReceiveError()
}

final class MapGuessViewModel {
  var delegate: MapGuessDelegate?
  
  private(set) var model: MapGuessModel = .init()
  
  
  // MARK: statistics
  
  var numCitiesGuessed: Int { model.guessedCities.count }
  var populationGuessed: Int { model.guessedCities.reduce(0) { $0 + $1.population } }
  
  private var citiesGuessedSortedIncreasing: [City] {
    model.guessedCities.sorted { c1, c2 in
      if c1.population == c2.population {
        if c1.name == c2.name {
          return c1.fullTitle < c2.fullTitle
        }
        return c1.name < c2.name
      }
      return c1.population < c2.population
    }
  }
  
  var largestGuessed: [City] {
    citiesGuessedSortedIncreasing.suffix(10)
  }
  
  var smallestGuessed: [City] {
    citiesGuessedSortedIncreasing.prefix(10).asArray
  }
  
  var rarestGuessed: [City] {
    model.guessedCities.sorted { c1, c2 in
      (c1.percentageOfSessions ?? 0.0) < (c2.percentageOfSessions ?? 0.0)
    }.prefix(10).asArray
  }
  
  var percentageTotalPopulationGuessed: Double {
    guard let config = model.gameConfiguration else {
      return 0
    }
    return populationGuessed / config.totalPopulation.asDouble
  }
  
  init() {
    let decoder = JSONDecoder()
    if let savedGameState = UserDefaults.standard.object(forKey: "gamestate") as? Data,
       let decodedModel = try? decoder.decode(MapGuessModel.self, from: savedGameState) {
      model = decodedModel
    } else {
      model = .init()
      retrieveConfiguration()
    }
  }
  
  private func retrieveConfiguration() {
    HMCRequestHandler.retrieveConfiguration { [weak self] config in
      self?.model.gameConfiguration = config
    }
  }
  
  func saveGameState() {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(model) {
      UserDefaults.standard.set(encoded, forKey: "gamestate")
    }
  }
  
  func submitGuess(_ guess: String) {
    HMCRequestHandler.submitGuess(guess) { [weak self] response in
      if let cities = response?.cities,
         !cities.isEmpty {
        self?.model.usedMultiCityInput ||= (cities.count > 1)
        
        var newCities = [City]()
        cities.forEach { city in
          let result = self?.model.guessedCities.insert(city)
          if result?.inserted ?? false {
            newCities.append(city)
          }
        }
        
        if newCities.isEmpty {
          self?.delegate?.didReceiveError()
        } else {
          self?.delegate?.didReceiveCities(newCities)
        }
      } else {
        self?.delegate?.didReceiveError()
      }
    }
  }
  
  func resetState() {
    model.resetState()
  }
  
  func finishGame() {
    HMCRequestHandler.finishGame(cities: Array(model.guessedCities), startTime: model.startTime, usedMultiCityInput: model.usedMultiCityInput) { res in
      print("yeah saved")
      print(res)
    }
  }
}

struct MapGuessModel: Codable {
  var guessedCities: Set<City> = .init()
  var gameConfiguration: GameConfiguration?
  var startTime: Date = .now
  var usedMultiCityInput: Bool = false
  
  mutating func resetState() {
    guessedCities = .init()
  }
}
