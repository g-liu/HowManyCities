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
  
  var numCitiesGuessed: Int { model.guessedCities.count }
  var populationGuessed: Int { model.guessedCities.reduce(0) { $0 + $1.population } }
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
}

struct MapGuessModel: Codable {
  var guessedCities: Set<City> = .init()
  var gameConfiguration: GameConfiguration?
}
