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
    var runningArea: CGFloat = 0
    (0..<pointCount).forEach {
      let nextIndex = ($0 + 1) % pointCount
      runningArea += points()[$0].x * points()[nextIndex].y
      runningArea -= points()[$0].y * points()[nextIndex].x
    }
    return runningArea / 2.0
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
      return points().mean(pointCount)
    }
    
    var centerX = 0.0
    var centerY = 0.0
    var runningArea = area
    (0..<pointCount).forEach {
      let nextIndex = ($0 + 1) % pointCount
      let factor1 = points()[$0].x * points()[nextIndex].y - points()[nextIndex].x * points()[$0].y
      centerX += (points()[$0].x + points()[nextIndex].x) * factor1
      centerY += (points()[$0].y + points()[nextIndex].y) * factor1
    }
    
    runningArea *= 6.0
    let factor2 = 1.0 / runningArea
    centerX *= factor2
    centerY *= factor2
    
    return .init(x: centerX, y: centerY)
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
