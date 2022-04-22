//
//  MKZoomableCircleRenderer.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/21/22.
//

import Foundation
import MapKit

final class MKZoomableCircleRenderer: MKCircleRenderer {
  override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
    context.saveGState()
    if let fillColor = fillColor {
      context.setFillColor(fillColor.cgColor)
    }
    // TODO: These properties are not applying when calling `addEllipse`
    context.setLineWidth(lineWidth)
    if let strokeColor = strokeColor {
      context.setStrokeColor(strokeColor.cgColor)
    }
    
    let scaleFactor = scaleFactor(at: zoomScale)
    let rekt = rect(for: circle.boundingMapRect) * scaleFactor
    context.addEllipse(in: rekt)
    
    context.closePath()
//    context.strokePath()
    context.drawPath(using: .fillStroke)
//    context.fillPath(using: .winding)
    context.restoreGState()
  }
}
