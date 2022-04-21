//
//  CGRect+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/20/22.
//

import Foundation
import UIKit

extension CGRect {
  static func *(lhs: Self, rhs: Double) -> Self {
    .init(center: lhs.center, size: lhs.size * rhs)
  }
}
