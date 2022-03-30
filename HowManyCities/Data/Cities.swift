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
    // The circle size is proportional to the city's population, on a logarithmic scale
    let absoluteSize = 200_000 * log10(0.000_019*(population+100_000))+13_000
    // We must account for the distortion caused by the Mercator projection, otherwise
    // cities closer to the poles will appear to have larger circles
    // See https://en.wikipedia.org/wiki/Mercator_projection#Scale_factor for details.
    let relativeSize = absoluteSize * __cospi(latitude/180.0)
    return relativeSize
  }
  
  var asShape: MKOverlay {
    if stateCapital || nationalCapital {
      return asStar
    } else {
      return asCircle
    }
  }
  
  private var asCircle: MKCircle {
    // TODO: This will depend on the gamemode!
    .init(center: coordinates, radius: circleSize)
  }
  
  var asStar: MKPolygon {
    let corners = 5
    let smoothness = 0.5
    let angleAdjustment = .pi * 2 / CGFloat(corners * 2)
    let center = MKMapPoint(coordinates)
    
    // ???
    let scaleFactor = (200_000 * log10(0.000_019*(population+100_000))+13_000) * 8
    
    let coordinates = (0..<10).map { i -> MKMapPoint in
      let scaleFactor = (i.isOdd ? smoothness : 1) * scaleFactor
      let xCoordinate = scaleFactor * cos(.pi/2.0 - i*angleAdjustment) + center.x
      let yCoordinate = scaleFactor * sin(.pi/2.0 - i*angleAdjustment) + center.y
      
//      return .init(latitude: xCoordinate, longitude: yCoordinate)
      return .init(x: xCoordinate, y: yCoordinate)
    }
    
    
    return .init(points: coordinates, count: coordinates.count)
//    return .init(coordinates: coordinates, count: coordinates.count)
  }
}
