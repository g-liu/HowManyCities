//
//  CLLocationCoordinate2D+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/30/22.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
  static let zero: Self = .init(latitude: 0, longitude: 0)
  
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

extension CLLocationCoordinate2D: Codable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    try container.encode(longitude)
    try container.encode(latitude)
  }
  
  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    let longitude = try container.decode(CLLocationDegrees.self)
    let latitude = try container.decode(CLLocationDegrees.self)
    self.init(latitude: latitude, longitude: longitude)
  }
}
