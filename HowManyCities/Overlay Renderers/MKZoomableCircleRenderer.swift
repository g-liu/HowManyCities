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
//    super.draw(mapRect, zoomScale: zoomScale, in: context)
    context.saveGState()
    context.setBlendMode(.normal)
    if let fillColor = fillColor {
      context.setFillColor(fillColor.cgColor)
    }
    // TODO: These properties are not applying when calling `addEllipse`
    context.setLineWidth(lineWidth)
    if let strokeColor = strokeColor {
      context.setStrokeColor(strokeColor.cgColor)
    }
    
    
//    let centerPoint = MKMapPoint(circle.coordinate)
//
//    context.move(to: CGPoint(x: centerPoint.x, y: centerPoint.y))
//    context.addLine(to: .init(x: 0, y: 0)) // LMAO IDK
    let scaleFactor = scaleFactor(at: zoomScale)
    let rekt = rect(for: circle.boundingMapRect) * scaleFactor // (1.0 / (1.0+Double(zoomScale.asLevel-3)))
    context.addEllipse(in: rekt)
    
//    print("ZOOM LEVEL???? \(zoomScale.asLevel)")
//    print("MAP RECT???? \(mapRect)")
//    print(zoomScale.asLevel)
    
    context.closePath()
    context.drawPath(using: .fillStroke)
    context.restoreGState()
//
//    print("idk???")
//    print(mapRect)
//    print(zoomScale)
  }
}
