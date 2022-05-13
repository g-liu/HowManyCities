//
//  CityAnnotationView.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import Foundation
import MapKit

final class CityAnnotationView: MKAnnotationView {
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    let img = UIImage.checkmark
    image = img
    frame = .init(x: 0, y: 0, width: 32, height: 32) // TODO: CHK
    contentMode = .scaleAspectFit
    centerOffset = .init(x: 0, y: -20)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func draw(_ layer: CALayer, in ctx: CGContext) {
    print("YEAHHHHDRAWING")
  }
}
