//
//  CityinfoViewModel.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/11/22.
//

import Foundation

struct CityInfoViewModel {
  weak var statsProvider: GameStatisticsProvider?
  
//  private let nearbyThreshold: Double = 500_000 // in meters
  
  var city: City /*{
    didSet {
      if let city = city, let statsProvider = statsProvider {
        nearbyCities = statsProvider.guessedCities(near: city).prefix(10).filter { city.distance(to: $0) < nearbyThreshold }
      } else {
        nearbyCities = []
      }
      configure(with: city)
    }
  }*/
  
  var nearbyCities: [City]? { statsProvider?.guessedCities(near: city, threshold: 500_000, limit: 10) }
  
  var nearestCity: City? { statsProvider?.nearestCity(to: city) }
  
  init(city: City, statsProvider: GameStatisticsProvider?) {
    self.city = city
    self.statsProvider = statsProvider
    
    setupModel()
  }
  
  private func setupModel() {
    
  }
  
  
}
