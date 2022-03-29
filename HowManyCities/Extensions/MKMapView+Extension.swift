//
//  MKMapView+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import MapKit

extension MKMapView {
  func closeAllAnnotations(animated: Bool = true) {
    selectedAnnotations.forEach { deselectAnnotation($0, animated: animated) }
  }
}
