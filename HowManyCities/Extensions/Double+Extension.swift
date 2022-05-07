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
    let nf = NumberFormatter()
    nf.numberStyle = .percent
//    nf.minimumIntegerDigits = 1
    
    nf.minimumIntegerDigits = 1
    nf.minimumFractionDigits = 0
    nf.roundingMode = .halfEven
    
    if self == 0 {
      nf.maximumFractionDigits = 0
    } else {
      nf.maximumFractionDigits = Int(Foundation.ceil(-log10(Swift.abs(self))))
    }
    
    if Swift.abs(self) < 0.001 {
      nf.maximumFractionDigits -= 2
    }
    
//    if self >= 1.0 {
//      nf.maximumFractionDigits = 0
//    } else if self >= 0.1 {
//      nf.maximumFractionDigits = 1
//    } else if self >= 0.01 {
//      nf.maximumFractionDigits = 2
//    } else if self >= 0.001 {
//      nf.maximumFractionDigits = 3
//    }  else {
//      nf.maximumFractionDigits = 4
//    }
    
    return nf.string(from: self as NSNumber) ?? "\(self)%"
    
//    let value = Foundation.round(self * 100000.0) / 1000.0
//    if self > 0.0 && value == 0 {
//      return "<0.001%"
//    }
//    return "\(value)%"
  }
}
