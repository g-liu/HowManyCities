//
//  MultiCityPopulationRenderer.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 5/9/22.
//

import UIKit


final class MultiCityPopulationRenderer: ItemRenderer {
  func string(_ item: [City]) -> NSAttributedString {
    let population = item.first?.population ?? 0
    
    let mas: NSMutableAttributedString
    let firstFewCitiesNames = item.prefix(3).map(by: \.nameWithStateAbbr).joined(separator: "; ")
    let flagString: String = item.flags.isEmpty ? "" : "\(item.flags) "
    mas = .init(string: "\(flagString)\(firstFewCitiesNames)")
    if item.count > 3 {
      let numCitiesRemaining = item.count - 3
      // TODO: Proper pluralization
      let remainingString = numCitiesRemaining > 1 ? "…and \(numCitiesRemaining.commaSeparated) others" : "…and \(numCitiesRemaining) other"
      mas.append(.init(string: "\n\t\(remainingString)  ", attributes: [.font: UIFont.italicSystemFont(ofSize: UIFont.labelFontSize),
                                                                      .foregroundColor: UIColor.label.withAlphaComponent(0.8)]))
    } else {
      mas.append(.init(string: "  "))
    }
    
    mas.append(.init(string: population.abbreviated, attributes: [.font: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                                                                       .foregroundColor: UIColor.systemGray]))
    
    return .init(attributedString: mas)
  }
}
