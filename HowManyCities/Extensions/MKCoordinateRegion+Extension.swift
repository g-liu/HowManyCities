//
//  MKCoordinateRegion+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/30/22.
//

import Foundation
import MapKit

extension MKCoordinateRegion: Codable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    try container.encode(center)
    try container.encode(span)
  }
  
  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    let center = try container.decode(CLLocationCoordinate2D.self)
    let span = try container.decode(MKCoordinateSpan.self)
    
    self.init(center: center, span: span)
  }
}
