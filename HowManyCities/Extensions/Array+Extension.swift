//
//  Array+Extension.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/11/22.
//

import Foundation

extension Array where Element == City {
  var totalPopulation: Int { reduce(0) { $0 + $1.population } }
  
  /// Contains the flags of the countries the cities represent,
  /// up to 3 flags for the three most represented countries in descending order
  var flags: String {
    Dictionary(grouping: self, by: \.countryFlag).sorted(by: \.value.count, with: >).compactMap(by: \.key).prefix(3).asArray.joined()
  }
}

extension Array where Element: NSAttributedString {
    func joined(separator: NSAttributedString) -> NSAttributedString {
        guard let firstElement = first else { return NSMutableAttributedString(string: "") }
        return dropFirst().reduce(into: NSMutableAttributedString(attributedString: firstElement)) { result, element in
            result.append(separator)
            result.append(element)
        }
    }

    func joined(separator: String) -> NSAttributedString {
        guard let firstElement = first else { return NSMutableAttributedString(string: "") }
        let attributedStringSeparator = NSAttributedString(string: separator)
        return dropFirst().reduce(into: NSMutableAttributedString(attributedString: firstElement)) { result, element in
            result.append(attributedStringSeparator)
            result.append(element)
        }
    }
}

extension Array {
  func isIndexValid(_ index: Int) -> Bool { index >= 0 && index < count }
}
