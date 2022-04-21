//
//  MKMapPoint+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/21/22.
//

import Foundation
import MapKit

extension MKMapPoint: Equatable {
  
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.coordinate == rhs.coordinate
  }
}

extension MKMapPoint {
  static var zero: Self { .init(x: 0, y: 0) }
  
  static func +(lhs: Self, rhs: Self) -> Self {
    .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
  }
  
  static func /(lhs: Self, rhs: Double) -> Self {
    .init(x: lhs.x / rhs, y: lhs.y / rhs)
  }
}
