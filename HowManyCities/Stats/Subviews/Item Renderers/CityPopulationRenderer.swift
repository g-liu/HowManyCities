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
    let firstFewCitiesNames = item.prefix(3).map { $0.name } // TODO: Also add state and country if nec.
    mas = .init(string: "\(firstFewCitiesNames.joined(separator: "; "))")
    if item.count > 3 {
      let numCitiesRemaining = item.count - 3
      // TODO: Proper pluralization
      let remainingString = numCitiesRemaining > 1 ? "…and \(numCitiesRemaining.commaSeparated) others" : "…and \(numCitiesRemaining) other"
      mas.append(.init(string: "\n\(remainingString)  ", attributes: [.font: UIFont.italicSystemFont(ofSize: UIFont.labelFontSize)]))
    }
    
    mas.append(.init(string: population.abbreviated, attributes: [.font: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                                                                       .foregroundColor: UIColor.systemGray]))
    
    return .init(attributedString: mas)
  }
}
