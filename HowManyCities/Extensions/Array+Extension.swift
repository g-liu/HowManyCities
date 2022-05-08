//
//  Array+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/11/22.
//

import Foundation

extension Array where Element == City {
  var totalPopulation: Int { reduce(0) { $0 + $1.population } }
}

extension Array {
  func isIndexValid(_ index: Int) -> Bool { index >= 0 && index < count }
}
