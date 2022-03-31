//
//  CLLocationCoordinate2D+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/30/22.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
  static func +(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
    .init(latitude: lhs.latitude + rhs.latitude, longitude: lhs.longitude + rhs.longitude)
  }
  
  static func /(lhs: CLLocationCoordinate2D, rhs: Int) -> CLLocationCoordinate2D {
    lhs / rhs.asDouble
  }
  
  static func /(lhs: CLLocationCoordinate2D, rhs: Double) -> CLLocationCoordinate2D {
    .init(latitude: lhs.latitude / rhs, longitude: lhs.longitude / rhs)
  }
}
