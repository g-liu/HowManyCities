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
    let mas = NSMutableAttributedString(string: "\(item.countryFlag) \(item.name) ")
    if let capitalDesignation = item.capitalDesignation {
      mas.append(.init(string: capitalDesignation, attributes: [.foregroundColor: UIColor.systemYellow]))
    }
    mas.append(.init(string: "  "))
    mas.append(.init(string: item.population.abbreviated, attributes: [.font: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                                                                       .foregroundColor: UIColor.systemGray]))
    
    return .init(attributedString: mas)
  }
}
