//
//  Bool+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/30/22.
//

import Foundation

infix operator ||= : AssignmentPrecedence
extension Bool {
  static func ||= (lhs: inout Bool, rhs: Bool) {
    lhs = lhs || rhs
  }
}
