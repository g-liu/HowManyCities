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
}
