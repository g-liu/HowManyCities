//
//  CityAnnotation.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import MapKit

final class CityAnnotation: NSObject, MKAnnotation {
  @objc dynamic var coordinate: CLLocationCoordinate2D
  
  var title: String?
  var subtitle: String?
  
  init(_ city: City) {
    self.coordinate = city.coordinates
    self.title = city.fullTitle
    self.subtitle = "pop: \(city.population.commaSeparated)" // TODO: Localize
  }
}
