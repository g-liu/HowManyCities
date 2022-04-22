//
//  CGSize+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/20/22.
//

import Foundation
import UIKit

extension CGSize {
  static func *(lhs: Self, rhs: Double) -> Self {
    .init(width: lhs.width * rhs, height: lhs.height * rhs)
  }
}
