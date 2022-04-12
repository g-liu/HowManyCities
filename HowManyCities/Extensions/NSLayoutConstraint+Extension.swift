//
//  NSLayoutConstraint+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/11/22.
//

import UIKit

extension NSLayoutConstraint {
  @discardableResult
  func with(priority: UILayoutPriority) -> Self {
    self.priority = priority
    return self
  }
}
