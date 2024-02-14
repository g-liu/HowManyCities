//
//  CityAnnotationView.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import Foundation
import MapKit

final class CityAnnotationView: MKAnnotationView {
  var originalFrame: CGRect?
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    originalFrame = nil
  }
  
  func setZoom(_ level: Int) {
    if originalFrame == nil {
      originalFrame = frame
    }
    
    guard let originalFrame = originalFrame else {
      return
    }

    // TODO: FINE TUNE THIS
    let scaleFactor = pow(1.5, level-3.0)
    frame.size.width = originalFrame.size.width * scaleFactor
    frame.size.height = originalFrame.size.height * scaleFactor
  }
}
