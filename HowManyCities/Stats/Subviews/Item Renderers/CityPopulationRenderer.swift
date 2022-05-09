//
//  CityItemRenderer.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/28/22.
//

import UIKit

final class CityPopulationRenderer: ItemRenderer {
  func render(_ item: City) -> UIView? {
    let label = UILabel().autolayoutEnabled
    label.numberOfLines = 2
    label.attributedText = string(item)
    
    return label
  }
  
  func string(_ item: City) -> NSAttributedString {
    let mas: NSMutableAttributedString
    if let countryFlag = item.countryFlag {
      mas = .init(string: "\(countryFlag) \(item.nameWithStateAbbr) ")
    } else {
      mas = .init(string: "\(item.nameWithStateAbbr)")
    }
    
    if let capitalDesignation = item.capitalDesignation {
      mas.append(.init(string: capitalDesignation, attributes: [.foregroundColor: UIColor.systemYellow]))
    }
    mas.append(.init(string: "  "))
    mas.append(.init(string: item.population.abbreviated, attributes: [.font: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                                                                       .foregroundColor: UIColor.systemGray]))
    
    return .init(attributedString: mas)
  }
}


final class MultiCityPopulationRenderer: ItemRenderer {
  typealias Item = [City]
  
  func render(_ item: [City]) -> UIView? {
    nil
  }
  
  func string(_ item: [City]) -> NSAttributedString {
    let population = item.first?.population ?? 0
    
    let mas: NSMutableAttributedString
    let firstFewCitiesNames = item.prefix(3).map(by: \.name) // TODO: Also add state and country if nec.
    let flagString: String = item.flags.isEmpty ? "" : "\(item.flags) "
    mas = .init(string: "\(flagString)\(firstFewCitiesNames.joined(separator: "; "))")
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
