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
  
  func submitGuess(_ guess: String) {
    HMCRequestHandler.submitRequest(string: guess) { [weak self] response in
      if let cities = response?.cities,
         !cities.isEmpty {
        self?.delegate?.didReceiveCities(cities)
      } else {
        self?.delegate?.didReceiveError()
      }
    }
    
  }
}
