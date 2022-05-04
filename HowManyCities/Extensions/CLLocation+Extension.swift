//
//  CLLocation+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/3/22.
//

import Foundation
import CoreLocation

extension CLLocation {
  convenience init(_ coordinates: CLLocationCoordinate2D) {
    self.init(latitude: coordinates.latitude, longitude: coordinates.longitude)
  }
}
