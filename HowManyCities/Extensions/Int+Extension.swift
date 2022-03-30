//
//  Int+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/29/22.
//

import UIKit

extension Int {
  var asDouble: Double { .init(self) }
  var asFloat: Float { .init(self) }
  var asCGFloat: CGFloat { .init(self) }
  var asNSNumber: NSNumber { .init(integerLiteral: self) }
  
  // MARK: - Addition
  
  static func +(left: Int, right: Double) -> Double {
    left.asDouble + right
  }
  
  static func +(left: Int, right: Float) -> Float {
    left.asFloat + right
  }
  
  static func +(left: Int, right: CGFloat) -> CGFloat {
    left.asCGFloat + right
  }
  
  // MARK: - Subtraction
  
  static func -(left: Int, right: Double) -> Double {
    left.asDouble - right
  }
  
  static func -(left: Int, right: Float) -> Float {
    left.asFloat - right
  }
  
  static func -(left: Int, right: CGFloat) -> CGFloat {
    left.asCGFloat - right
  }
  
  // MARK: - Multiplication
  
  static func *(left: Int, right: Double) -> Double {
    left.asDouble * right
  }
  
  static func *(left: Int, right: Float) -> Float {
    left.asFloat * right
  }
  
  static func *(left: Int, right: CGFloat) -> CGFloat {
    left.asCGFloat * right
  }
  
  // MARK: - Division
  
  static func /(left: Int, right: Double) -> Double {
    left.asDouble / right
  }
  
  static func /(left: Int, right: Float) -> Float {
    left.asFloat / right
  }
  
  static func /(left: Int, right: CGFloat) -> CGFloat {
    left.asCGFloat / right
  }
  
  var commaSeparated: String? {
    let fmt = NumberFormatter()
    fmt.numberStyle = .decimal
    return fmt.string(from: asNSNumber)
  }
  
  var abbreviated: String {
    let absValue = Swift.abs(self)
    let sign = self >= 0 ? "" : "-"
    
    if abs < 1000 { return "\(self)" }
    
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    let numberValue: Double
    let qualifier: String
    
    numberFormatter.maximumFractionDigits = (2-(digitsCount-1)%3)
    
    if 1_000 <= absValue && absValue < 1_000_000 {
      numberValue = absValue / 1_000.0
      qualifier = "K"
    } else if 1_000_000 <= absValue && absValue < 1_000_000_000 {
      numberValue = absValue / 1_000_000.0
      qualifier = "M"
    } else if 1_000_000_000 <= absValue && absValue < 1_000_000_000_000 {
      numberValue = absValue / 1_000_000_000.0
      qualifier = "B"
    } else {
      numberValue = absValue / 1_000_000_000_000.0
      qualifier = "T"
    }
    
    guard let numberString = numberFormatter.string(from: numberValue.asNSNumber) else {
      return "\(self)"
    }
    return "\(sign)\(numberString)\(qualifier)"
  }
}
