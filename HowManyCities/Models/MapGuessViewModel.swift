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
  weak var delegate: MapGuessDelegate?
  
  private var guessedCities: Set<City> = .init()
  var gameConfiguration: GameConfiguration?
  
  var numCitiesGuessed: Int { guessedCities.count }
  var populationGuessed: Int { guessedCities.reduce(0) { $0 + $1.population } }
  dynamic var percentageTotalPopulationGuessed: Double {
    guard let config = gameConfiguration else {
      return 0
    }
    return populationGuessed / config.totalPopulation.asDouble
  }
  
  init() {
    retrieveConfiguration()
  }
  
  private func retrieveConfiguration() {
    HMCRequestHandler.retrieveConfiguration { [weak self] config in
      self?.gameConfiguration = config
    }
  }
  
  func submitGuess(_ guess: String) {
    HMCRequestHandler.submitGuess(guess) { [weak self] response in
      if let cities = response?.cities,
         !cities.isEmpty {
        var newCities = [City]()
        cities.forEach { city in
          let result = self?.guessedCities.insert(city)
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
}
