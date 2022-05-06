//
//  Double+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import UIKit
import Foundation

extension Double {
  var asInt: Int { .init(self) }
  var asFloat: Float { .init(self) }
  var asCGFloat: CGFloat { .init(self) }
  var asNSNumber: NSNumber { .init(value: self) }
  
  // TODO: Format very small percentages to the first N non-zero decimal places
  var asPercentString: String {
    let value = Foundation.round(self * 100000.0) / 1000.0
    if self > 0.0 && value == 0 {
      return "<0.001%"
    }
    return "\(value)%"
  }
}
