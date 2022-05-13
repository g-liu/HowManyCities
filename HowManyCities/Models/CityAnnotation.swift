//
//  CityAnnotation.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import MapKit
import Foundation

final class CityAnnotation: NSObject, MKAnnotation {
  @objc dynamic var coordinate: CLLocationCoordinate2D
  
  var title: String?
  var subtitle: String?
  let preferredSize: CGRect
  
  init(_ city: City) {
//    let sideDimension = Int(max(log2(Float(city.population)) + 1, 1))
//    let sideDimension = Double(city.population) / 700_000.0 + 5.0
    // Logistic function
//    let sideDimension = 35 / (1+exp(-0.0000003*(city.population-10_000_000))) + 5
//    let sideDimension = 2 * log2(max(1.0,Double(city.population))) + 1
    let sideDimension = pow(city.population.asDouble, 0.2)
    self.preferredSize = .init(x: 0,y: 0,width: sideDimension, height: sideDimension)
    self.coordinate = city.coordinates
    self.title = city.fullTitle
    self.subtitle = "pop: \(city.population.commaSeparated)" // TODO: Localize
  }
}
