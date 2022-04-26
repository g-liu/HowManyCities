//
//  MapGuessViewModel.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import Foundation
import CoreLocation
import MapKit

protocol MapGuessDelegate: AnyObject {
  func didReceiveCities(_ cities: [City])
  func didReceiveError(_ error: CityGuessError)
  func didSaveResult(_ response: GameFinishResponse?)
  
  func didChangeGuessMode(_ mode: GuessMode)
}

final class MapGuessViewModel: NSObject {
  var delegate: MapGuessDelegate?
  
  private(set) var guessMode: GuessMode = .any
  
  private var model: MapGuessModel = .init()
  
  var lastRegion: MKCoordinateRegion {
    get {
      model.lastRegion
    } set {
      model.lastRegion = newValue
    }
  }
  
  var numCitiesGuessed: Int { model.numCitiesGuessed }
  var populationGuessed: Int { model.populationGuessed }
  var percentageTotalPopulationGuessed: Double { model.percentageTotalPopulationGuessed }
  
  override init() {
    super.init()
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
    HMCRequestHandler.shared.retrieveConfiguration { [weak self] config in
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
    let formattedGuess: String
    if case .any = guessMode {
      formattedGuess = guess
    } else {
      formattedGuess = guess + ", \(guessMode.string)"
    }
    
    HMCRequestHandler.shared.submitGuess(formattedGuess) { [weak self] response in
      if let cities = response?.cities {
        if !cities.isEmpty {
          self?.model.usedMultiCityInput ||= (cities.count > 1)
          
          var newCities = [City]()
          cities.forEach { city in
            let result = self?.model.guessedCities.insert(city)
            if result?.inserted ?? false {
              newCities.append(city)
            }
          }
          
          if newCities.isEmpty {
            self?.delegate?.didReceiveError(.alreadyGuessed)
          } else {
            self?.delegate?.didReceiveCities(newCities)
          }
        } else {
          self?.delegate?.didReceiveError(.noneFound(guess))
        }
      } else {
        self?.delegate?.didReceiveError(.serverError)
      }
    }
  }
  
  var guessedCities: Set<City> {
    model.guessedCities
  }
  
  func resetState() {
    model.resetState()
  }
  
  func finishGame() {
    HMCRequestHandler.shared.finishGame(cities: Array(model.guessedCities), startTime: model.startTime, usedMultiCityInput: model.usedMultiCityInput) { [weak self] res in
      self?.delegate?.didSaveResult(res)
    }
  }
}

extension MapGuessViewModel: GuessModeDelegate {
  func didChangeGuessMode(_ mode: GuessMode) {
    guessMode = mode
    delegate?.didChangeGuessMode(mode)
  }
}

extension MapGuessViewModel: StatesDataSource {
  var topLevelStates: [State] {
    model.gameConfiguration?.topLevelStates ?? []
  }
  
  var lowerDivisionStates: [State] {
    model.gameConfiguration?.lowerDivisionStates ?? []
  }
}
