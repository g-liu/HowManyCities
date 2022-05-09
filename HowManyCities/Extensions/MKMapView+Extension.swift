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
  
  func searchAndLocate(_ place: String) {
    let req = MKLocalSearch.Request()
    req.naturalLanguageQuery = place
    req.region = .full
    
    let search = MKLocalSearch(request: req)
    search.start { response, error in
      if let boundingRect = response?.boundingRegion,
         response?.mapItems.count == 1 {
        self.setRegion(boundingRect, animated: true)
      } else if let mapItem = response?.mapItems.first(where: {$0.placemark.title?.contains($0.placemark.name ?? "💩") ?? false}) {
        if let boundingCircle = mapItem.placemark.region as? CLCircularRegion {
          self.setRegion(.init(center: boundingCircle.center, latitudinalMeters: boundingCircle.radius * 1.2, longitudinalMeters: boundingCircle.radius * 1.2), animated: true)
        } else if let location = mapItem.placemark.location {
          self.setRegion(.init(center: location.coordinate, span: self.region.span), animated: true)
        } else {
          self.setRegion(.init(center: mapItem.placemark.coordinate, span: self.region.span), animated: true)
        }
      } else {
        // Sorry bud can't help you.
      }
    }
  }
}
