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
    let mas = NSMutableAttributedString(string: "\(item.countryFlag) \(item.name) ")
    mas.append(.init(string: item.capitalDesignation, attributes: [.foregroundColor: UIColor.systemYellow]))
    mas.append(.init(string: "  "))
    mas.append(.init(string: item.population.abbreviated, attributes: [.font: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                                                                       .foregroundColor: UIColor.systemGray]))
    
    label.attributedText = mas
    
    return label
  }
}
