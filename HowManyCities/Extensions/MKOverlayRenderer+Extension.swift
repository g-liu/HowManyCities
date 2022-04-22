//
//  MKOverlayRenderer+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/21/22.
//

import MapKit

extension MKOverlayRenderer {
  func scaleFactor(at zoomScale: MKZoomScale) -> Double {
    1.0 / pow(1.5, zoomScale.asLevel-3)
  }
}
