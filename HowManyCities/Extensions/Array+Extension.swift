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
