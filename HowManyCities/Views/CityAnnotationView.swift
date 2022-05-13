//
//  CityAnnotationView.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import Foundation
import MapKit

final class CityAnnotationView: MKAnnotationView {
  private lazy var sublayer: CALayer = {
    let sublayer = CALayer()
    sublayer.backgroundColor = UIColor.systemRed.withAlphaComponent(0.5).cgColor
    sublayer.borderWidth = 1.0
    sublayer.borderColor = UIColor.systemFill.cgColor

    return sublayer
  }()
  
  override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
    super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    
    canShowCallout = true
    
//    layer.backgroundColor = UIColor.systemRed.withAlphaComponent(0.5).cgColor
//    layer.borderWidth = 1.0
//    layer.borderColor = UIColor.systemFill.cgColor

    layer.addSublayer(sublayer)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
//  override func layoutSubviews() {
//    super.layoutSubviews()
//
//    sublayer.frame = bounds
//  }
  
  func setFrame(_ frame: CGRect) {
    self.frame = frame
    sublayer.frame = frame
  }
  
  func setCornerRadius(_ radius: CGFloat) {
    sublayer.cornerRadius = radius
  }
  
  func applyTransform(_ scaleFactor: Double) {
    sublayer.transform = .init(scaleX: scaleFactor, y: scaleFactor, z: 1.0)
    sublayer.borderWidth = 1.0 / scaleFactor
  }
  
  func toggle(selected: Bool) {
    sublayer.backgroundColor = sublayer.backgroundColor?.copy(alpha: selected ? 1.0 : 0.5)
  }
}
