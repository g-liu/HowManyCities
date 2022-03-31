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
  let percentageOfSessions: Double?
  
  var fullTitle: String {
    [name, state, territory, country].filter { !$0.isEmpty }.joined(separator: ", ")
  }
  
  var coordinates: CLLocationCoordinate2D {
    .init(latitude: latitude, longitude: longitude)
  }
  
  // The circle size is proportional to the city's population, on a logarithmic scale
  private var absoluteSize: CLLocationDistance {
    175_000 * log10(0.000_05*(population+25_000))
  }
  
  private var circleSize: CLLocationDistance {
    // We must account for the distortion caused by the Mercator projection, otherwise
    // cities closer to the poles will appear to have larger circles
    // See https://en.wikipedia.org/wiki/Mercator_projection#Scale_factor for details.
    absoluteSize * __cospi(latitude/180.0)
  }
  
  var asShape: MKOverlay {
    // TODO: This will depend on the gamemode!
    if /*stateCapital || */nationalCapital {
      return asStar
    } else {
      return asCircle
    }
  }
  
  private var asCircle: MKCircle {
    .init(center: coordinates, radius: circleSize)
  }
  
  private var asStar: MKPolygon {
    let corners = 5
    let smoothness = 0.5
    let angleAdjustment = .pi * 2 / CGFloat(corners * 2)
    let center = MKMapPoint(coordinates)
    
    let scaleFactor = absoluteSize * 8
    
    let coordinates = (0..<10).map { i -> MKMapPoint in
      let scaleFactor = (i.isOdd ? smoothness : 1) * scaleFactor
      let xCoordinate = scaleFactor * cos(.pi/2.0 - i*angleAdjustment) + center.x
      let yCoordinate = scaleFactor * sin(.pi/2.0 - i*angleAdjustment) + center.y
      
      return .init(x: xCoordinate, y: yCoordinate)
    }
    
    return .init(points: coordinates, count: coordinates.count)
  }
}

extension City {
  var asShortForm: CityShortForm {
    .init(pk: pk, name: name)
  }
}
