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
    context.saveGState()
    let scaleFactor = scaleFactor(at: zoomScale)
    
    if let fillColor = fillColor {
      context.setFillColor(fillColor.cgColor)
    }
    let nominalLineWidth: CGFloat = 100000 * lineWidth * scaleFactor
    context.setLineWidth(nominalLineWidth)
    if let strokeColor = strokeColor {
      context.setStrokeColor(strokeColor.cgColor)
    }
    
    let polygonCenter = polygon.centroid

    if polygon.pointCount > 1 {
      context.beginPath()
      
      (0..<polygon.pointCount).forEach {
        let nextPoint = point(for: polygon.points()[$0].scaled(to: polygonCenter, by: scaleFactor))
        if $0 == 0 {
          context.move(to: nextPoint)
        } else {
          context.addLine(to: nextPoint)
        }
      }
      
      context.closePath()
//      context.strokePath()
      context.drawPath(using: .fillStroke)
//      context.fillPath(using: .winding)
    }
    
    context.restoreGState()
  }
}
