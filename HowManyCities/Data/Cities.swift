//
//  Cities.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import Foundation
import MapKit

struct Cities: Codable {
  let cities: [City]
}

struct City: Codable, Hashable {
  let name: String
  let state: String
  let territory: String
  let country: String
  let latitude: Double
  let longitude: Double
  let population: Int
  let stateCapital: Bool
  let nationalCapital: Bool
  let pk: Int
//  let code: AnyObject // I HAVE NO FUCKING CLUE
  let quiz: String
  let archived: Bool
  let percentageOfSessions: Double
  
  var fullTitle: String {
    [name, state, territory, country].filter { !$0.isEmpty }.joined(separator: ", ")
  }
  
  var coordinates: CLLocationCoordinate2D {
    .init(latitude: latitude, longitude: longitude)
  }
  
  private var circleSize: CLLocationDistance {
    200_000 * log10(0.000_019*(population+100_000))+13_000
  }
  
  var asCircle: MKCircle {
    .init(center: coordinates, radius: circleSize)
  }
}
