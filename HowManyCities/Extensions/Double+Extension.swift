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
  
  var asPercentString: String {
    let value = Foundation.round(self * 10000.0) / 100.0
    return "\(value)%"
  }
}
