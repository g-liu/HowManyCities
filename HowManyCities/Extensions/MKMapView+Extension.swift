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
  
  func searchAndLocate(_ place: String, regionCb: ((MKCoordinateRegion?) -> Void)? = nil) {
    let req = MKLocalSearch.Request()
    req.naturalLanguageQuery = place
    req.region = .full
    
    let search = MKLocalSearch(request: req)
    search.start { response, error in
      if let boundingRect = response?.boundingRegion,
         response?.mapItems.count == 1 {
        self.setRegion(boundingRect, animated: true)
        regionCb?(boundingRect)
      } else if let mapItem = response?.mapItems.first(where: {$0.placemark.title?.contains($0.placemark.name ?? "💩") ?? false}) {
        if let boundingCircle = mapItem.placemark.region as? CLCircularRegion {
          let region = MKCoordinateRegion(center: boundingCircle.center, latitudinalMeters: boundingCircle.radius * 1.2, longitudinalMeters: boundingCircle.radius * 1.2)
          self.setRegion(region, animated: true)
          regionCb?(region)
        } else if let location = mapItem.placemark.location {
          let region = MKCoordinateRegion(center: location.coordinate, span: self.region.span)
          self.setRegion(region, animated: true)
          regionCb?(region)
        } else {
          let region = MKCoordinateRegion(center: mapItem.placemark.coordinate, span: self.region.span)
          self.setRegion(region, animated: true)
          regionCb?(region)
        }
      } else {
        // Sorry bud can't help you.
        regionCb?(nil)
      }
    }
  }
}
