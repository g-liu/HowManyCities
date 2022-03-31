//
//  ArraySlice+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 3/30/22.
//

import Foundation

extension ArraySlice {
  var asArray: [Element] { Array(self) }
}
