//
//  CityRarityRenderer.swift
//  HowManyCities
//
//  Created by Geoffrey Liu on 4/28/22.
//

import UIKit

final class CityRarityRenderer: ItemRenderer {
  func render(_ item: City) -> UIView? {
    let label = UILabel().autolayoutEnabled
    label.numberOfLines = 2
    label.attributedText = string(item)
    
    return label
  }
  
  func string(_ item: City) -> NSAttributedString {
    let rarity = item.percentageOfSessions ?? 0.0
    
    let mas = NSMutableAttributedString(string: "\(item.countryFlag) \(item.nameWithStateAbbr)  ")
    mas.append(.init(string: rarity.asPercentString, attributes: [.font: UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                                                                       .foregroundColor: UIColor.systemGray]))
    
    return .init(attributedString: mas)
  }
}
