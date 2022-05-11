//
//  UIView+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import UIKit

extension UIView {
  var autolayoutEnabled: Self {
    translatesAutoresizingMaskIntoConstraints = false
    return self
  }
  
  func pin(to otherView: UIView, margins: UIEdgeInsets = .zero) {
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: otherView.topAnchor, constant: margins.top),
      bottomAnchor.constraint(equalTo: otherView.bottomAnchor, constant: -margins.bottom),
      leadingAnchor.constraint(equalTo: otherView.leadingAnchor, constant: margins.left),
      trailingAnchor.constraint(equalTo: otherView.trailingAnchor, constant: -margins.right),
    ])
  }
  
  func pin(to layoutGuide: UILayoutGuide, margins: UIEdgeInsets = .zero) {
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: margins.top),
      bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -margins.bottom),
      leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: margins.left),
      trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -margins.right),
    ])
  }
  
  func pinSides(to otherView: UIView, margins: UIEdgeInsets = .zero) {
    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: otherView.leadingAnchor, constant: margins.left),
      trailingAnchor.constraint(equalTo: otherView.trailingAnchor, constant: -margins.right),
    ])
  }
  
  func pinSides(to layoutGuide: UILayoutGuide, margins: UIEdgeInsets = .zero) {
    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: margins.left),
      trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -margins.right),
    ])
  }
}

extension UIView {
  static func animate(animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
    self.animate(withDuration: CATransaction.animationDuration(), animations: animations, completion: completion)
  }
  
  func removeAllGestureRecognizers() {
    gestureRecognizers?.forEach { removeGestureRecognizer($0) }
  }
}

