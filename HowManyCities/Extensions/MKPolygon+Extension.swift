//
//  MKPolygon+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/21/22.
//

import Foundation
import MapKit
import CoreAudio

extension MKPolygon {
  var area: CGFloat {
    0.5 * (0..<pointCount).reduce(0.0) {
      let nextIndex = ($1 + 1) % pointCount
      let thisPoint = points()[$1]
      let nextPoint = points()[nextIndex]
      
      return $0 + thisPoint.x*nextPoint.y - thisPoint.y*nextPoint.x
    }
  }
  
  var center: MKMapPoint {
    points().mean(pointCount)
  }
  
  // https://stackoverflow.com/questions/53569830/how-can-i-find-the-center-coordinate-in-a-mglmultipolygonfeature
  var centroid: MKMapPoint {
    if pointCount == 0 {
      return .init(x: Double.nan, y: Double.nan)
    }
    
    if pointCount == 1 {
      return points()[0]
    }
    
    if pointCount == 2 {
      return center
    }
    
    let runningCentroid = (0..<pointCount).reduce(MKMapPoint.zero) {
      let nextIndex = ($1 + 1) % pointCount
      let thisPoint = points()[$1]
      let nextPoint = points()[nextIndex]
      
      let factor1 = thisPoint.x * nextPoint.y - nextPoint.x * thisPoint.y
      let nextCentroid = MKMapPoint(x: thisPoint.x + nextPoint.x, y: thisPoint.y + nextPoint.y) * factor1
      
      return $0 + nextCentroid
    }
    
    return runningCentroid * (1.0 / (6.0*area))
  }
}

extension Array where Element == MKMapPoint {
  var mean: MKMapPoint {
    let sum = reduce(.zero) { $0 + $1 }
    return sum / Double(count)
  }
}

extension UnsafeMutablePointer where Pointee == MKMapPoint {
  func mean(_ count: Int) -> MKMapPoint {
    var sum: MKMapPoint = .zero
    (0..<count).forEach {
      sum = sum + self[$0]
    }
    return sum / Double(count)
  }
}
