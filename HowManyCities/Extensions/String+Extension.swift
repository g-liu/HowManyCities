//
//  String+Range.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/5/22.
//

import Foundation

extension String {
  var entireRange: NSRange {
    .init(self.startIndex..<self.endIndex, in: self)
  }
}
