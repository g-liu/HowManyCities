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
    let scaleFactor = scaleFactor(at: zoomScale)
    
    if let fillColor = fillColor {
      context.setFillColor(fillColor.cgColor)
    }
    let nominalLineWidth: CGFloat = 100000 * lineWidth * scaleFactor
    context.setLineWidth(nominalLineWidth)
    if let strokeColor = strokeColor {
      context.setStrokeColor(strokeColor.cgColor)
    }
    
    
    let rekt = rect(for: circle.boundingMapRect) * scaleFactor
    context.addEllipse(in: rekt)
    
    context.closePath()
//    context.strokePath()
    context.drawPath(using: .fillStroke)
//    context.fillPath(using: .winding)
    context.restoreGState()
  }
}
