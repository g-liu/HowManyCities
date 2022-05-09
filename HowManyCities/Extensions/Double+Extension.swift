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
    
    return nf.string(from: self as NSNumber) ?? "\(self)%"
  }
}
