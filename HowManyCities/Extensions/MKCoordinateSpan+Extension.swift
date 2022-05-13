//
//  MKCoordinateSpan+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/30/22.
//

import Foundation
import MapKit

extension MKCoordinateSpan {
  static let full: Self = .init(latitudeDelta: 180, longitudeDelta: 360)
}

extension MKCoordinateSpan: Codable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    try container.encode(longitudeDelta)
    try container.encode(latitudeDelta)
  }
  
  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    let longitudeDelta = try container.decode(CLLocationDegrees.self)
    let latitudeDelta = try container.decode(CLLocationDegrees.self)
    self.init(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
  }
}

extension MKCoordinateSpan: Equatable {
  public static func == (lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {
    lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == rhs.longitudeDelta
  }
}
