//
//  MKZoomablePolygonRenderer.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/21/22.
//

import Foundation
import MapKit

final class MKZoomablePolygonRenderer: MKPolygonRenderer {
  override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
//    super.draw(mapRect, zoomScale: zoomScale, in: context)
    context.saveGState()
    context.setBlendMode(.normal)
    if let fillColor = fillColor {
      context.setFillColor(fillColor.cgColor)
    }
    context.setLineWidth(lineWidth)
    if let strokeColor = strokeColor {
      context.setStrokeColor(strokeColor.cgColor)
    }
    
    if polygon.pointCount > 1 {
      context.beginPath()
      
      let firstPoint = point(for: polygon.points()[0])
      context.move(to: firstPoint)
      
      (1..<polygon.pointCount).forEach {
        let nextPoint = point(for: polygon.points()[$0])
        context.addLine(to: nextPoint)
      }
      
      context.closePath()
      context.drawPath(using: .fillStroke)
    }
    
    print("WE DREW SOME POINTS")
    print(polygon.points())
    
    context.restoreGState()
  }
}
