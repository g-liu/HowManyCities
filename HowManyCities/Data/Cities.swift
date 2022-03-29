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

struct City: Codable {
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
  
  var coordinates: CLLocationCoordinate2D {
    .init(latitude: latitude, longitude: longitude)
  }
  
  private var circleSize: CLLocationDistance {
    
//    if population < 10_000 {
//      return 4E4
//    }
//
//
//    if population < 100_000 {
//      return 7E4
//    } else if 100_000 <= population && population < 1_000_000 {
//      return 1E5
//    } else if 1_000_000 <= population && population < 10_000_000 {
//      return 3E5
//    } else {
//      return 5E5
//    }
    200_000 * log10(0.000_019*(population+100_000))+13_000
  }
  
  var asCircle: MKCircle {
    .init(center: coordinates, radius: circleSize)
  }
}
